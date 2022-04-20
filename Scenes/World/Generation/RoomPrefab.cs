using Godot;
using Godot.Collections;

public class RoomPrefab : Node2D
{
    [Export]
    private PackedScene _barrierScene;
    [Export]
    private PackedScene _levelExitScene;
    [Export]
    private PackedScene _spawnerScene;


    public int AStarIndex;
    public Array Doors;

    private Array _barriers;
    private Array _barrierTiles;

    private Array _spawners;
    private Array _spawnerTiles;

    private Vector2 _exitTile;
    public LevelExit exit = null;

    private Player _player;
    private Navigation2D _nav;
    private DropSpawner _dropSpawner;

    private TileMap _globalMap;

    public TileMap TileMap;
    private TileMap _spawnMap;

    private Area2D _area;
    private NavigationPolygonInstance _navPoly;

    public override void _Ready()
    {
        TileMap = GetNode<TileMap>("Terrain");
        _spawnMap = GetNode<TileMap>("Spawns");

        _area = GetNode<Area2D>("Area2D");
        _navPoly = GetNode<NavigationPolygonInstance>("NavigationPolygonInstance");

        SetProcess(false);

        Doors = TileMap.GetUsedCellsById(TileMap.TileSet.FindTileByName("Door"));
        _barrierTiles = _spawnMap.GetUsedCellsById(_spawnMap.TileSet.FindTileByName("Door"));
        _spawnerTiles = _spawnMap.GetUsedCellsById(_spawnMap.TileSet.FindTileByName("Spawner"));
        if (RotationDegrees == 90)
        {
            Vector2 offset = new Vector2(0, _spawnMap.CellSize.x);
            _spawnMap.Position -= offset;
            _navPoly.Position -= offset;
            _area.Position -= offset;
        }

        SpawnSpawners();
    }


    public void Init(Player player, Navigation2D nav, TileMap map, DropSpawner dropSpawner)
    {
        _player = player;
        _nav = nav;
        _globalMap = map;
        _dropSpawner = dropSpawner;
    }


    public void AttachNavPoly()
    {
        int _poly = _nav.NavpolyAdd(_navPoly.Navpoly, _navPoly.GlobalTransform);
    }


    public void SpawnBarriers()
    {
        for (int i = 0; i < _barrierTiles.Count; i++)
        {
            Vector2 b = (Vector2)_barrierTiles[i];
            if (RotationDegrees == 90)
            {
                b -= Vector2.Up;
            }
            Vector2 spawnPos = _spawnMap.MapToWorld(b);
            Vector2 pos = _spawnMap.ToGlobal(spawnPos);
            Vector2 mapPos = _globalMap.WorldToMap(_globalMap.ToLocal(pos));

            if (_globalMap.GetCellv(mapPos) == _globalMap.TileSet.FindTileByName("Floor"))
            {
                Barrier barrier = _barrierScene.Instance() as Barrier;
                barrier.Position = spawnPos + Vector2.One * _spawnMap.CellSize / 2;
                if (RotationDegrees == 90)
                {
                    barrier.Position -= new Vector2(0, _spawnMap.CellSize.x) * 2;
                }

                switch (i)
                {
                    case 0:
                        _exitTile = (Vector2)_barrierTiles[3];
                        break;
                    case 1:
                        _exitTile = (Vector2)_barrierTiles[2];
                        barrier.RotationDegrees = -90;
                        break;
                    case 2:
                        _exitTile = (Vector2)_barrierTiles[1];
                        barrier.RotationDegrees = -90;
                        break;
                    case 3:
                        _exitTile = (Vector2)_barrierTiles[0];
                        break;
                }

                _barriers.Add(barrier);
                AddChild(barrier);
                barrier.SetActive(false);
            }
        }
    }

    private void SpawnSpawners()
    {
        foreach (Vector2 s in _spawnerTiles)
        {
            Spawner spawner = _spawnerScene.Instance() as Spawner;
            spawner.Position = _spawnMap.MapToWorld(s) + Vector2.One * _spawnMap.CellSize / 2;
            if (RotationDegrees == 90)
            {
                spawner.Position -= new Vector2(0, _spawnMap.CellSize.x);
            }
            _spawners.Add(spawner);
            AddChild(spawner);
            spawner.Init(_nav, _player, _dropSpawner);
            spawner.Health.Invincible = true;
        }
    }


    public LevelExit AddLevelExit()
    {
        Vector2 exitPosition = _spawnMap.MapToWorld(_exitTile) + Vector2.One * _spawnMap.CellSize / 2;
        exit = _levelExitScene.Instance() as LevelExit;
        exit.Position = exitPosition;
        if (exit.Position.y == (_spawnMap.CellSize / 2).y)
        {
            exit.RotationDegrees = -90;
        }
        if (RotationDegrees == 90)
        {
            exit.Position -= new Vector2(0, _spawnMap.CellSize.x);
        }
        AddChild(exit);
        exit.SetActive(false);
        return exit;
    }


    private void ActivateLevelExit()
    {
        Array toClear = new Array(_exitTile);
        if (exit.RotationDegrees == 90)
        {
            toClear.Add(_exitTile + Vector2.Up);
            toClear.Add(_exitTile + Vector2.Down);
        }
        else
        {
            toClear.Add(_exitTile + Vector2.Left);
            toClear.Add(_exitTile + Vector2.Right);
        }

        foreach (Vector2 v in toClear)
        {
            Vector2 vec = v;
            if (RotationDegrees == 90)
            {
                vec -= Vector2.Up;
            }
            Vector2 mapPos = _globalMap.WorldToMap(_globalMap.ToLocal(_spawnMap.ToGlobal(_spawnMap.MapToWorld(vec))));
            _globalMap.SetCellv(mapPos, -1);
            exit.SetActive(true);
        }
    }


    public void ActivateArea()
    {
        _area.CollisionMask = 2;
        _area.Monitoring = true;
    }


    public bool HasIndex(int i)
    {
        return i == AStarIndex;
    }

    public override void _Process(float delta)
    {
        TryOpenRoom();
    }


    private void TryOpenRoom()
    {
        foreach (Spawner spawner in _spawners)
        {
            if (IsInstanceValid(spawner))
            {
                return;
            }
        }

        SetProcess(false);

        foreach (Barrier b in _barriers)
        {
            b.SetActive(false);
        }

        if (exit != null)
        {
            ActivateLevelExit();
        }
    }


    public void OnRoomAreaBodyEntered(PhysicsBody2D body)
    {
        if (body is Player)
        {
            foreach (Spawner s in _spawners)
            {
                if (IsInstanceValid(s))
                {
                    s.Health.Invincible = false;
                    s.SpawnDelay.Start();
                }
            }

            foreach (Barrier b in _barriers)
            {
                b.SetActive(true);
            }
            SetProcess(true);
        }
    }


    public void OnRoomAreaBodyExited(PhysicsBody2D body)
    {
        if (body is Player)
        {
            _area.SetDeferred("Monitoring", false);
        }
    }
}
