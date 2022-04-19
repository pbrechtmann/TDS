using Godot;
using System;

public class PauseMenu : CanvasLayer
{
    private MarginContainer _margin;

    private Game _game;
    private Player _player;

    public override void _Ready()
    {
        _margin = GetNode<MarginContainer>("Control/marginContainer");

        PauseMode = Node.PauseModeEnum.Process;
        GetTree().Paused = true;

        Vector2 window = OS.WindowSize;

        _margin.MarginTop = window.y / 3.6f;
        _margin.MarginBottom = -_margin.MarginTop;
        _margin.MarginLeft = window.x / 2.4f;
        _margin.MarginRight = -_margin.MarginLeft;
    }


    public void Init(Game game, Player player)
    {
        _game = game;
        _player = player;
    }


    public void OnButtonContinueButtonDown()
    {
        GetTree().Paused = false;
        _player.SetActive(true);
        QueueFree();
    }


    public void OnButtonSettingsButtonDown()
    {
        // TODO: pauseMode = Process
    }


    public void OnButtonMenuButtonDown()
    {
        GetTree().Paused = false;
        if (GetTree().ChangeScene("res://Scenes/Menus/Main/MainMenu.tscn") != Error.Ok)
        {
            GD.PrintErr("Loading main menu scene failed.");
        }
    }


    public void OnButtonQuitButtonDown()
    {
        GetTree().Quit();
    }
}
