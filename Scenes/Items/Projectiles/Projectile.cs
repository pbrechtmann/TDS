using Godot;
using System;

public class Projectile : Node2D
{
    private Vector2 _direction = Vector2.Zero;

    private float _speed = 1000;

    private int _pierce = 0;

    private Entity _source;

    private RayCast2D _collisionRay;
    public override void _Ready()
    {
        _collisionRay = GetNode<RayCast2D>("RayCast2D");
    }

    public void Init(Transform2D muzzleTransform, Vector2 direction, Entity source)
    { // TODO: Add damage
        SetAsToplevel(true);
        _direction = direction;
        GlobalTransform = muzzleTransform;
    }

    public override void _PhysicsProcess(float delta)
    {
        Position += _direction * delta * _speed;
    }

    private bool HandlePierce()
    {
        if (_pierce > 0)
        {
            _pierce--;
            return false;
        }
        return true;
    }


    private void Impact(PhysicsBody2D body)
    {
        bool done = true;

        if (body is Entity)
        {
            Entity target = (Entity)body;

            target.GetDamage();
            done = HandlePierce();
        }

        if (done)
        {
            QueueFree();
        }
    }


    public void OnArea2DBodyEntered(PhysicsBody2D body)
    {
        Impact(body);
    }

}
