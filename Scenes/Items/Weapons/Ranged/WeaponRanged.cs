using Godot;
using System;


public class WeaponRanged : Weapon
{
    [Export] public PackedScene ProjectileScene;
    public Position2D Muzzle;
    public override void _Ready()
    {
        Muzzle = GetNode<Position2D>("Muzzle");
    }

    private void PrimaryAttack()
    {
        Projectile projectile = ProjectileScene.Instance() as Projectile;
        projectile.Init(Muzzle.GlobalTransform, GlobalPosition.DirectionTo(Muzzle.GlobalPosition), User); // TODO: Pass damage

        AddChild(projectile);
    }
}
