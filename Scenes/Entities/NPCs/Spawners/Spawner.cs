using Godot;
using System;

public class Spawner : NPC
{
    [Export] private PackedScene _toSpawn;

    public Timer SpawnDelay;
    private Sprite _sprite;
    private CollisionShape2D _collision;

    private Node2D _NPCContainer;
    public override void _Ready()
    {
        SpawnDelay = GetNode<Timer>("Timer");
        _sprite = GetNode<Sprite>("Sprite");
        _collision = GetNode<CollisionShape2D>("CollisionShape2D");
        SetProcess(false);
    }

    private NPC CreateNPC()
    {
        NPC newNPC = _toSpawn.Instance() as NPC;
        newNPC.Init(Nav, Target, DropSpawner);

        return newNPC;
    }

    public override void _Process(float delta)
    {
        if (_NPCContainer.GetChildCount() == 0)
        {
            SetProcess(false);
            QueueFree();
        }
    }


    public void OnSpawnDelayTimeout()
    {
        _NPCContainer.AddChild(CreateNPC());
    }


    public new void OnHealthDeath()
    {
        _sprite.Visible = false;

        if (IsInstanceValid(_collision))
        {
            _collision.QueueFree();
        }

        SpawnDelay.Stop();
        SetProcess(true);
    }
}