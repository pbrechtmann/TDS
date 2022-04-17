using Godot;
using System;


public class WeaponRanged : Weapon
{
    [Export] PackedScene projectileScene;
    public Position2D muzzle;
    public override void _Ready()
    {
        muzzle = GetNode<Position2D>("Muzzle");
    }

    private void PrimaryAttack()
    {
        Projectile projectile = projectileScene.Instance() as Projectile;
        projectile.Init(muzzle.GlobalTransform, GlobalPosition.DirectionTo(muzzle.GlobalPosition), user); // TODO: Pass damage

        AddChild(projectile);
    }
}
