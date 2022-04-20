using Godot;
using Godot.Collections;
using System.Collections.Generic;

public class Generator : Node2D
{
    [Export]
    private int _tileSize = 128;
    [Export]
    private int _spacer = 6;
    [Export]
    private bool _cyclicPaths = false;
    [Export]
    private int _roomsSmall;
    [Export]
    private Array _sizesSmall;
    [Export]
    private int _roomsMedium;
    [Export]
    private Array _sizesMedium;
    [Export]
    private int _roomsLarge;
    [Export]
    private Array _sizesLarge;
    [Export]
    private PackedScene _roomBodyScene;

    private Vector2 _startPosition;
    private Player _player;
    private Navigation2D _nav;
    private DropSpawner _dropSpawner;

    private Node _roomContainer;
    private Node2D _mapContainer;
    private TileMap _map;

    private Array _roomBodies;

    private AStar2D _path;
    private AStar2D _doorConnections;
    private Array _doorPoints;

    private RoomBody _startRoom;
    private RoomBody _endRoom;

    public LevelExit Exit;

    [Signal]
    public delegate void Done();

    public override void _Ready()
    {
        _roomContainer = GetNode<Node>("Rooms");
        _mapContainer = GetNode<Node2D>("Maps");
        _map = GetNode<TileMap>("Maps/TerrainMap");

        foreach (Vector2 size in _sizesSmall)
        {
            _sizesSmall.Add(new Vector2(size.y, size.x));
        }
        foreach (Vector2 size in _sizesMedium)
        {
            _sizesMedium.Add(new Vector2(size.y, size.x));
        }
        foreach (Vector2 size in _sizesLarge)
        {
            _sizesLarge.Add(new Vector2(size.y, size.x));
        }
    }


    public async void GenerateLevel(Player player, Navigation2D nav, DropSpawner dropSpawner)
    {
        _player = player;
        _nav = nav;
        _dropSpawner = dropSpawner;

        foreach (Node item in _roomContainer.GetChildren())
        {
            item.QueueFree();
        }

        foreach (Node item in _map.GetChildren())
        {
            item.QueueFree();
        }

        _map.Clear();

        GD.Randomize();

        MakeRooms();
        await ToSignal(GetTree().CreateTimer(0.1f), "timeout");
        MakeMap();
    }


    private async void MakeRooms()
    {
        Array roomsSmall = GenerateRoomBodies(_roomsSmall, _sizesSmall);
        Array roomsMedium = GenerateRoomBodies(_roomsMedium, _sizesMedium);
        Array roomsLarge = GenerateRoomBodies(_roomsLarge, _sizesLarge);
        // TODO Array roomsBoss = GenerateRoomBodies();

        _roomBodies = roomsSmall + roomsMedium + roomsLarge;
        _roomBodies.Shuffle();

        foreach (RigidBody2D room in _roomBodies)
        {
            room.CollisionMask = 512;
            room.CollisionLayer = 512;
        }

        await ToSignal(GetTree().CreateTimer(0.1f), "timeout");

        foreach (RigidBody2D room in _roomBodies)
        {
            room.Position = room.Position.Snapped(Vector2.One * _tileSize);
            room.Mode = RigidBody2D.ModeEnum.Static;
        }

        FindGraph();
    }

    private Array GenerateRoomBodies(int amount, Array sizes)
    {
        Array result = new Array();

        while (amount > 0)
        {
            RoomBody room = _roomBodyScene.Instance() as RoomBody;
            room.Init((Vector2)sizes[(int)GD.Randi() % sizes.Count], Vector2.One * _spacer, _tileSize);
            room.Position = new Vector2((float)GD.RandRange(-1, 1), (float)GD.RandRange(-1, 1)).Clamped(1);
            result.Add(room);
            _roomContainer.CallDeferred("AddChild", room);
            amount--;
        }

        return result;
    }


    private void FindGraph()
    {
        _path = new AStar2D();
        Array rooms = _roomBodies.Duplicate();

        Vector2[] positions = new Vector2[rooms.Count];

        for (int i = 0; i < rooms.Count; i++)
        {
            RoomBody r = (RoomBody)rooms[i];
            r.AStarIndex = i;
            positions[i] = r.Position;
        }

        RoomBody room = (RoomBody)rooms[0];
        rooms.RemoveAt(0);

        _path.AddPoint(room.AStarIndex, room.Position);

        while (rooms.Count > 0)
        {

            float minDistance = float.MaxValue;
            RoomBody minRoom = null;
            Vector2 pos = Vector2.Zero;

            foreach (int point1 in _path.GetPoints())
            {
                Vector2 point1Position = _path.GetPointPosition(point1);

                foreach (RoomBody r in rooms)
                {
                    Vector2 point2Position = r.Position;
                    float testDistance = point1Position.DistanceTo(point2Position);

                    if (testDistance < minDistance)
                    {
                        minDistance = testDistance;
                        minRoom = r;
                        pos = point1Position;
                    }
                }
            }

            _path.AddPoint(minRoom.AStarIndex, minRoom.Position);
            _path.ConnectPoints(_path.GetClosestPoint(pos), minRoom.AStarIndex);

            rooms.Remove(minRoom);
        }

        FindStartAndEnd();

        if (_cyclicPaths)
        {
            List<int> delauney = new List<int>(Geometry.TriangulateDelaunay2d(positions));

            while (delauney.Count > 0)
            {
                int p1 = delauney[0];
                delauney.RemoveAt(0);
                int p2 = delauney[0];
                delauney.RemoveAt(0);
                int p3 = delauney[0];
                delauney.RemoveAt(0);


                if (IsLoopValid(p1, p2) && GD.Randf() < 0.2)
                { // TODO: remove magic number
                    _path.ConnectPoints(p1, p2);
                }
                if (IsLoopValid(p1, p3) && GD.Randf() < 0.2)
                { // TODO: remove magic number
                    _path.ConnectPoints(p1, p3);
                }
                if (IsLoopValid(p2, p3) && GD.Randf() < 0.2)
                { // TODO: remove magic number
                    _path.ConnectPoints(p2, p3);
                }

            }
        }
    }


    private bool IsLoopValid(int p1, int p2)
    { // TODO : remove magic number
        return (!_path.ArePointsConnected(p1, p2) && _path.GetPointPath(p1, p2).Length == 3 && !(HasStartRoom(p1, p2) || HasEndRoom(p1, p2)));
    }


    private bool HasStartRoom(int p1, int p2)
    {
        if (_startRoom != null)
        {
            return p1 == _startRoom.AStarIndex || p2 == _startRoom.AStarIndex;
        }
        return false;
    }


    private bool HasEndRoom(int p1, int p2)
    {
        if (_endRoom != null)
        {
            return p1 == _endRoom.AStarIndex || p2 == _endRoom.AStarIndex;
        }
        return false;
    }


    private void FindStartAndEnd()
    {
        Array leafRoomsIndex = new Array();
        Array leafRooms = new Array();

        foreach (int point in _path.GetPoints())
        {
            if (_path.GetPointConnections(point).Length == 1)
            {
                leafRoomsIndex.Add(point);
            }
        }

        foreach (RoomBody room in _roomBodies)
        {
            for (int i = 0; i < leafRoomsIndex.Count; i++)
            {
                if (room.HasIndex((int)leafRoomsIndex[i]))
                {
                    leafRooms.Add(room);
                }
            }
        }

        RoomBody start = null;
        RoomBody end = null;
        int pathLenght = 0;

        while (leafRooms.Count == 0)
        {
            RoomBody s = (RoomBody)leafRooms[0];
            leafRooms.RemoveAt(0);

            foreach (RoomBody r in leafRooms)
            {
                int l = _path.GetIdPath(s.AStarIndex, r.AStarIndex).Length;
                if (l > pathLenght)
                {
                    pathLenght = l;
                    start = s;
                    end = r;
                }
            }
        }

        if (start.Size > end.Size)
        {
            RoomBody temp = end;
            end = start;
            start = temp;
        }

        _startRoom = start;
        _startPosition = _startRoom.GlobalPosition + Vector2.One * _tileSize / 2;
        _endRoom = end;
    }


    private void MakeMap()
    {
        foreach (RoomBody room in _roomBodies)
        {
            room.Position = room.Position.Snapped(Vector2.One * _tileSize);
        }
        _map.Clear();


        Rect2 fullMapRect = new Rect2();
        foreach (RoomBody room in _roomBodies)
        {
            Rect2 rect = RoomToRect(room);
            fullMapRect = fullMapRect.Merge(rect);
        }

        Vector2 topLeft = _map.WorldToMap(fullMapRect.Position);
        Vector2 bottomRight = _map.WorldToMap(fullMapRect.End);


        for (int x = (int)topLeft.x; x < bottomRight.x; x++)
        {
            for (int y = (int)topLeft.y; y < bottomRight.y; y++)
            {
                _map.SetCell(x, y, _map.TileSet.FindTileByName("ToFill"));
            }
        }

        foreach (RoomBody room in _roomBodies)
        {
            Vector2 size = (room.Size / _tileSize);
            Rect2 rect = RoomToRect(room, true);
            rect.Size += Vector2.One * _tileSize;

            Vector2 tL = _map.WorldToMap(rect.Position);
            Vector2 bR = _map.WorldToMap(rect.End);

            for (int x = (int)tL.x; x < bR.x; x++)
            {
                for (int y = (int)tL.y; y < bR.y; y++)
                {
                    _map.SetCell(x, y, -1);
                }
            }

            bool rotate = size.x <= size.y;
            float x_size = rotate ? size.x : size.y;
            float y_size = rotate ? size.y : size.x;

            RoomPrefab newRoom = ResourceLoader.Load<PackedScene>("res://Scenes/World/Generation/RoomPrefabs/RoomPrefab" + x_size + "x" + y_size + ".tscn").Instance() as RoomPrefab;
            newRoom.Position = room.Position;
            newRoom.AStarIndex = room.AStarIndex;

            newRoom.RotationDegrees = rotate ? 90 : 0;

            newRoom.Init(_player, _nav, _map, _dropSpawner);
            _map.AddChild(newRoom);
        }

        foreach (RoomBody room in _roomBodies)
        {
            RoomPrefab newRoom = new RoomPrefab();
            foreach (RoomPrefab r in _map.GetChildren())
            {
                if (r.HasIndex(room.AStarIndex))
                {
                    newRoom = r;
                }
                Array doorDirections = ConnectDoors(newRoom, room);
                MergeMaps(_map, newRoom.TileMap);
            }
        }

        LinkDoorGraph();
        CarveCorridors();
        PlaceWalls();
        _map.UpdateBitmaskRegion();

        _path.Clear();
        _doorConnections.Clear();
        _doorPoints.Clear();

        foreach (Node child in _roomContainer.GetChildren())
        {
            child.QueueFree();
        }
        _roomBodies.Clear();

        _player.GlobalPosition = _startPosition;

        foreach (RoomPrefab room in _map.GetChildren())
        {
            room.SpawnBarriers();
            room.ActivateArea();
            room.AttachNavPoly();
            if (room.AStarIndex == _endRoom.AStarIndex)
            {
                Exit = room.AddLevelExit();
            }
        }
        EmitSignal("Done");
    }


    private Array ConnectDoors(RoomPrefab roomPrefab, RoomBody room)
    {
        Array doors = roomPrefab.Doors.Duplicate();
        Array doorsUsed = new Array();

        if (roomPrefab.RotationDegrees == 90)
        {
            doors = new Array(doors[1], doors[3], doors[0], doors[2]);
        }

        foreach (RoomBody r in _roomBodies)
        {
            if (_path.ArePointsConnected(room.AStarIndex, r.AStarIndex))
            {
                Dictionary startDict = GetDoorDict(room, roomPrefab, doors, r);

                RoomPrefab tRoom = null;

                foreach (RoomPrefab x in _map.GetChildren())
                {
                    if (x.HasIndex(r.AStarIndex))
                    {
                        tRoom = x;
                    }
                }

                Array tDoors = tRoom.Doors;
                if (tRoom.RotationDegrees == 90)
                {
                    tDoors = new Array(tDoors[1], tDoors[3], tDoors[0], tDoors[2]);
                }

                Dictionary endDict = GetDoorDict(r, tRoom, tDoors, room);

                Array arg = new Array(startDict, endDict);

                _doorPoints.Add(arg);
                doorsUsed.Add(startDict["dir"]);
            }
        }
        return doorsUsed;
    }


    private Dictionary GetDoorDict(RoomBody startRoom, RoomPrefab startRoomPrefab, Array doors, RoomBody targetRoom)
    {
        RectangleShape2D shape = (RectangleShape2D)startRoom.Collision.Shape;
        Vector2 extents = shape.Extents;
        Vector2 center = startRoom.Position;

        Vector2 tL = center - extents;
        Vector2 tR = center + new Vector2(extents.x, -extents.y);
        Vector2 bL = center - new Vector2(extents.x, -extents.y);
        Vector2 bR = center + extents;

        float tLAngle = center.DirectionTo(tL).Angle();
        float tRAngle = center.DirectionTo(tR).Angle();
        float bLAngle = center.DirectionTo(bL).Angle();
        float bRAngle = center.DirectionTo(bR).Angle();

        float pathAngle = center.DirectionTo(targetRoom.Position).Angle();

        Vector2 doorLocation = Vector2.Zero;
        Vector2 doorDirection = Vector2.Zero;

        if (pathAngle >= tLAngle && pathAngle < tRAngle)
        {
            doorLocation = (Vector2)doors[0];
            doorDirection = Vector2.Up;
        }
        else if (pathAngle >= tRAngle && pathAngle < bRAngle)
        {
            doorLocation = (Vector2)doors[2];
            doorDirection = Vector2.Right;
        }
        else if (pathAngle >= tRAngle && pathAngle < bLAngle)
        {
            doorLocation = (Vector2)doors[3];
            doorDirection = Vector2.Down;
        }
        else
        {
            doorLocation = (Vector2)doors[1];
            doorDirection = Vector2.Left;
        }

        Dictionary result = new Dictionary();
        result.Add("pos", startRoomPrefab.TileMap.ToGlobal(startRoomPrefab.TileMap.MapToWorld(doorLocation)));
        result.Add("dir", doorDirection);

        return result;
    }


    private void LinkDoorGraph()
    {
        Dictionary linked = new Dictionary();
        _doorConnections = new AStar2D();

        foreach (Dictionary door in _doorPoints)
        {
            int val1;
            int val2;
            Dictionary d1 = (Dictionary)door[0];
            Dictionary d2 = (Dictionary)door[1];
            Vector2 pos1 = (Vector2)d1["pos"];
            Vector2 pos2 = (Vector2)d2["pos"];

            if (linked.Contains(pos1))
            {
                val1 = (int)linked[pos1];
                d1["index"] = val1;
            }
            else
            {
                val1 = _doorConnections.GetAvailablePointId();
                d1["index"] = val1;
                _doorConnections.AddPoint(val1, pos1);
            }

            if (linked.Contains(pos2))
            {
                val2 = (int)linked[pos2];
                d2["index"] = val2;
            }
            else
            {
                val2 = _doorConnections.GetAvailablePointId();
                d2["index"] = val2;
                linked[pos2] = val2;
                _doorConnections.AddPoint(val2, pos2);
            }
            _doorConnections.ConnectPoints(val1, val2);
        }
    }


    private void CarveCorridors()
    {
        AStar2D pathSearch = new AStar2D();
        for (int i = 0; i < _doorConnections.GetPointCount(); i++)
        {
            Vector2 door = _map.WorldToMap(_doorConnections.GetPointPosition(i));
            foreach (int connection in _doorConnections.GetPointConnections(i))
            {
                Vector2 target = _map.WorldToMap(_doorConnections.GetPointPosition(connection));

                int doorID = pathSearch.GetAvailablePointId();
                pathSearch.AddPoint(doorID, door);
                int targetID = pathSearch.GetAvailablePointId();
                pathSearch.AddPoint(targetID, target);

                Vector2 tL = new Vector2(Mathf.Min(door.x, target.x), Mathf.Max(door.y, target.y));
                Vector2 bR = new Vector2(Mathf.Max(door.x, target.x), Mathf.Min(door.y, target.y));

                int xDiff = (int)Mathf.Max(1, Mathf.Abs(tL.x - bR.x));
                int yDiff = (int)Mathf.Max(1, Mathf.Abs(tL.y - bR.y));

                for (int x = 0; x < xDiff; x++)
                {
                    for (int y = 0; y < yDiff; y++)
                    {
                        Vector2 pointPos = tL + new Vector2(x, -y);
                        if (IsTileValid(pointPos))
                        {
                            pathSearch.AddPoint(pathSearch.GetAvailablePointId(), pointPos, pointPos.DistanceSquaredTo(door));
                        }
                    }
                }

                foreach (int p in pathSearch.GetPoints())
                {
                    ConnectToDir(pathSearch, p, Vector2.Up);
                    ConnectToDir(pathSearch, p, Vector2.Down);
                    ConnectToDir(pathSearch, p, Vector2.Left);
                    ConnectToDir(pathSearch, p, Vector2.Right);

                    if (pathSearch.GetPointConnections(p).Length == 0)
                    {
                        ConnectToDir(pathSearch, p, Vector2.Up * 2);
                        ConnectToDir(pathSearch, p, Vector2.Down * 2);
                        ConnectToDir(pathSearch, p, Vector2.Left * 2);
                        ConnectToDir(pathSearch, p, Vector2.Right * 2);
                    }
                }

                Vector2[] corridor = pathSearch.GetPointPath(doorID, targetID);
                foreach (Vector2 p in corridor)
                {
                    int floorTile = _map.TileSet.FindTileByName("Floor");
                    _map.SetCellv(p, floorTile);
                    _map.SetCellv(p + Vector2.Up, floorTile);
                    _map.SetCellv(p + Vector2.Down, floorTile);
                    _map.SetCellv(p + Vector2.Left, floorTile);
                    _map.SetCellv(p + Vector2.Right, floorTile);
                    _map.SetCellv(p + Vector2.One, floorTile);
                    _map.SetCellv(p - Vector2.One, floorTile);
                    _map.SetCellv(p + new Vector2(-1, 1), floorTile);
                    _map.SetCellv(p + new Vector2(1, -1), floorTile);
                }
                _doorConnections.DisconnectPoints(i, connection);
                pathSearch.Clear();
            }
        }
    }


    private void ConnectToDir(AStar2D astar, int p, Vector2 dir)
    {
        int q = astar.GetClosestPoint(astar.GetPointPosition(p) + dir);
        if (q != p && !astar.ArePointsConnected(p, q))
        {
            astar.ConnectPoints(p, q);
        }
    }


    private bool IsTileValid(Vector2 pos)
    {
        Array invalid = new Array(_map.TileSet.FindTileByName("Wall"));
        Array positions = new Array(pos, pos + Vector2.Up, pos + Vector2.Down, pos + Vector2.Left, pos + Vector2.Right, pos + Vector2.One, pos + -Vector2.One, pos + new Vector2(-1, 1), pos + new Vector2(1, -1));
        foreach (Vector2 cell in positions)
        {
            if (invalid.Contains(_map.GetCellv(cell)))
            {
                return false;
            }
        }
        return true;
    }


    private void PlaceWalls()
    {
        int wallTile = _map.TileSet.FindTileByName("Wall");
        Array toFill = _map.GetUsedCellsById(_map.TileSet.FindTileByName("ToFill")) + _map.GetUsedCellsById(_map.TileSet.FindTileByName("Door"));
        foreach (Vector2 cell in toFill)
        {
            _map.SetCellv(cell, wallTile);
        }
    }


    private Vector2 Carve(Vector2 start, Vector2 direction, int steps, bool corner = false)
    {
        //TODO : Check if needed: Vector2 pos = Vector2.Zero + start;
        SetFloorCell(start, direction);
        if (corner)
        {
            SetFloorCell(start + direction * -1, direction);
        }

        for (int i = 0; i < steps; i++)
        {
            start += direction;
            SetFloorCell(start, direction);
        }

        if (corner)
        {
            SetFloorCell(start + direction, direction);
        }
        return start;
    }


    private void SetFloorCell(Vector2 pos, Vector2 dir)
    {
        int floorTile = _map.TileSet.FindTileByName("Floor");
        _map.SetCellv(pos, floorTile);
        if (dir == Vector2.Up || dir == Vector2.Down)
        {
            _map.SetCellv(pos + Vector2.Right, floorTile);
            _map.SetCellv(pos + Vector2.Left, floorTile);
        }
        else if (dir == Vector2.Left || dir == Vector2.Right)
        {
            _map.SetCellv(pos + Vector2.Up, floorTile);
            _map.SetCellv(pos + Vector2.Down, floorTile);
        }
    }


    private Vector2 GetDoorDir(int index)
    {
        foreach (Dictionary d in _doorPoints)
        {
            Dictionary inner = (Dictionary)d[0];
            if ((int)inner["index"] == index)
            {
                return (Vector2)inner["dir"];
            }
        }
        return Vector2.Zero;
    }


    private void MergeMaps(TileMap target, TileMap input)
    {
        Array cells = input.GetUsedCells();
        foreach (Vector2 cell in cells)
        {
            int tile = input.GetCellv(cell);
            Vector2 targetLocation = target.WorldToMap(target.ToLocal(input.ToGlobal(input.MapToWorld(cell))));
            target.SetCellv(targetLocation, tile);
        }
        input.Clear();
    }


    private Rect2 RoomToRect(RoomBody r, bool withSpacer = false)
    {
        RectangleShape2D shape = (RectangleShape2D)r.Collision.Shape;
        Vector2 roomExtents = shape.Extents;
        if (withSpacer)
        {
            roomExtents -= (Vector2.One * _spacer * _tileSize);
        }

        return new Rect2(r.Position - roomExtents, roomExtents * 2);
    }
}
