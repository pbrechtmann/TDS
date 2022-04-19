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
    private int _roomsMedium;
    [Export]
    private int _roomsLarge;
    [Export]
    private PackedScene _roomBodyScene;

    private Player _player;
    private Navigation2D _nav;
    private DropSpawner _dropSpawner;

    private Node _roomContainer;
    private Node2D _mapContainer;
    private TileMap _map;

    private Array _roomBodies;

    private AStar2D path;

    private RoomBody _startRoom;
    private RoomBody _endRoom;

    [Signal]
    public delegate void Done();

    public override void _Ready()
    {
        _roomContainer = GetNode<Node>("Rooms");
        _mapContainer = GetNode<Node2D>("Maps");
        _map = GetNode<TileMap>("Maps/TerrainMap");
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
        Array roomsSmall = GenerateRoomBodies(_roomsSmall);
        Array roomsMedium = GenerateRoomBodies(_roomsMedium);
        Array roomsLarge = GenerateRoomBodies(_roomsLarge);
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
        path = new AStar2D();
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

        path.AddPoint(room.AStarIndex, room.Position);

        while (rooms.Count > 0)
        {

            float minDistance = float.MaxValue;
            RoomBody minRoom = null;
            Vector2 pos = Vector2.Zero;

            foreach (int point1 in path.GetPoints())
            {
                Vector2 point1Position = path.GetPointPosition(point1);

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

            path.AddPoint(minRoom.AStarIndex, minRoom.Position);
            path.ConnectPoints(path.GetClosestPoint(pos), minRoom.AStarIndex);

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
                    path.ConnectPoints(p1, p2);
                }
                if (IsLoopValid(p1, p3) && GD.Randf() < 0.2)
                { // TODO: remove magic number
                    path.ConnectPoints(p1, p3);
                }
                if (IsLoopValid(p2, p3) && GD.Randf() < 0.2)
                { // TODO: remove magic number
                    path.ConnectPoints(p2, p3);
                }

            }
        }
    }


    private bool IsLoopValid(int p1, int p2)
    { // TODO : remove magic number
        return (!path.ArePointsConnected(p1, p2) && path.GetPointPath(p1, p2).Length == 3 && !(HasStartRoom(p1, p2) || HasEndRoom(p1, p2)));
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

        foreach (int point in path.GetPoints())
        {
            if (path.GetPointConnections(point).Length == 1)
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
                int l = path.GetIdPath(s.AStarIndex, r.AStarIndex).Length;
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
            RoomPrefab newRoom;
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

        path.Clear();
        doorConnections.Clear();
        doorPoints.Clear();

        foreach (Node child in _roomContainer.GetChildren())
        {
            child.QueueFree();
        }
        _roomBodies.Clear();

        _player.GlobalPosition = startPosition;

        foreach (RoomPrefab room in _map.GetChildren())
        {
            room.SpawnBarriers();
            room.ActivateArea();
            room.AttachNavPoly();
            if (room.Index == _endRoom.AStarIndex)
            {
                Exit = room.AddLevelExit();
            }
        }
        EmitSignal("Done");
    }
}
