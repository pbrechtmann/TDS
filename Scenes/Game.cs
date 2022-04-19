using Godot;
using System;

public class Game : Node
{
    private PackedScene _pauseMenu;

    private Generator _generator;

    private Player _player;
    private Navigation2D _nav;
    private DropSpawner _dropSpawner;

    private UI _ui;

    public override void _Ready()
    {
        _pauseMenu = ResourceLoader.Load<PackedScene>("res://Scenes/Menus/Pause/PauseMenu.tscn");

        _generator = GetNode<Generator>("Generator");

        _player = GetNode<Player>("Player");
        _nav = GetNode<Navigation2D>("Navigation2D");
        _dropSpawner = GetNode<DropSpawner>("DropSpawner");


        if (_player.Connect("GameOver", this, "OnPlayerGameOver") != Error.Ok)
        {
            GD.PrintErr("Connecting signal GameOver failed.");
        }
        if (_player.Connect("Pause", this, "OnPlayerPause") != Error.Ok)
        {
            GD.PrintErr("Connecting signal Pause failed.");
        }

        _player.Init(_dropSpawner);

        if (_generator.Connect("Done", this, "OnGeneratorDone") != Error.Ok)
        {
            GD.PrintErr("Connecting signal Done failed.");
        }

        Generate();

        _ui.Init(_player);
    }


    private async void Generate()
    {
        _player.ActionLock.AddActionLock();
        _player.ActionLock.AddMoveLock();
        _player.CollisionLayer = 0;

        await ToSignal(GetTree(), "idle_frame");

        _dropSpawner.Clear();
        _generator.GenerateLevel(_player, _nav, _dropSpawner);
    }


    public void OnPlayerGameOver()
    {
        GetTree().CallGroup("Entity", "QueueFree");
        if (GetTree().ReloadCurrentScene() != Error.Ok)
        {
            GD.PrintErr("Reloading game scene failed");
        }
    }


    public void OnPlayerPause()
    {
        _player.SetActive(false);
        PauseMenu pauseMenu = _pauseMenu.Instance() as PauseMenu;
        AddChild(pauseMenu);
        pauseMenu.Init(this, _player);
    }


    public async void OnGeneratorDone()
    {
        await ToSignal(GetTree(), "idle_frame");

        _player.CollisionLayer = 2 + 4;
        _player.SetActive(true);
        _player.ActionLock.RemoveActionLock();
        _player.ActionLock.RemoveMoveLock();

        if (_generator.Exit.Connect("LevelDone", this, "OnExitLevelDone") != Error.Ok)
        {
            GD.PrintErr("Connecting signal LevelDone failed.");
        }
    }


    public void OnExitLevelDone()
    {
        _player.SetActive(false);
        Generate();
    }
}
