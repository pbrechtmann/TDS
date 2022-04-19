using Godot;
using System;

public class RoomBody : RigidBody2D
{
    public Vector2 Size;
    public int AStarIndex;

    public CollisionShape2D Collision;

    public override void _Ready()
    {
        Collision = GetNode<CollisionShape2D>("CollisionShape2D");
    }

    public void Init(Vector2 size, Vector2 spacer, int tileSize)
    {
        Size = size * tileSize / 2;

        RectangleShape2D shape = new RectangleShape2D();
        shape.CustomSolverBias = 1;
        shape.Extents = size + spacer * tileSize;
        GetNode<CollisionShape2D>("CollisionShape2D").Shape = shape;
        size *= 2;
    }

    public bool HasIndex(int index)
    {
        return index == AStarIndex;
    }
}
