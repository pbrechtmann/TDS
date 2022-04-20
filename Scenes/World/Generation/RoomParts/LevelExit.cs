using Godot;
using System;

public class LevelExit : Area2D
{
    private Sprite _sprite;

    [Signal]
    public delegate void LevelDone();

    public override void _Ready()
    {
        _sprite = GetNode<Sprite>("Sprite");
    }

    public void SetActive(bool active)
    {
        CollisionMask = (uint)(active ? 2 : 0);
        _sprite.Visible = active;
    }


    public void OnLevelExitBodyEntered(PhysicsBody2D body)
    {
        if (body is Player)
        {
            EmitSignal("LevelDone");
        }
    }
}
