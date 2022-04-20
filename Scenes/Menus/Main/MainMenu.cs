using Godot;
using System;

public class MainMenu : Control
{
    private MarginContainer _margin;


    public override void _Ready()
    {
        _margin = GetNode<MarginContainer>("MarginContainer");

        Vector2 window = OS.WindowSize;

        _margin.MarginTop = window.y / 1.44f;
        _margin.MarginBottom = window.y / -21.6f;
        _margin.MarginLeft = window.x / 38.4f;
        _margin.MarginRight = window.x / -1.28f;
    }


    public void OnButtonStartButtonDown()
    {
        if (GetTree().ChangeScene("res://Scenes/Game.tscn") != Error.Ok)
        {
            GD.PrintErr("Loading game scene failed.");
        }
    }


    public void OnButtonSettingsButtonDown()
    {
        //TODO
    }


    public void OnButtonQuitButtonDown()
    {
        GetTree().Quit();
    }
}