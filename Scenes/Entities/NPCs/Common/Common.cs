using Godot;
using System;

public class Common : NPC
{
    private Weapon _weapon;

    private float threshold = 75;
    public override void _Ready()
    {
        _weapon = GetNode<Weapon>("Fists");
        _weapon.Init(this, 0, false);
    }

    private void Move()
    {
        Vector2[] path = Nav.GetSimplePath(GlobalPosition, Target.GlobalPosition);
        if (path.Length > 1)
        {
            Vector2 move = GlobalPosition.DirectionTo(path[1]).Normalized();
            move = MoveAndSlide(move * Speed * StatMods.Speed);
            LookAt(GlobalPosition + move);
        }
    }

    public override void _PhysicsProcess(float delta)
    {
        if (ActionLock.IsMoveLocked()) return;
        Move();
    }

    public override void _Process(float delta)
    {
        if (ActionLock.IsActionLocked()) return;

        if (_weapon.GlobalPosition.DistanceTo(Target.GlobalPosition) <= threshold)
        {
            _weapon.TryPrimaryAttack(EnergySupply);
        }
    }


    public new void OnHealthDeath()
    {
        if (!dead)
        {
            dead = true;
            DropSpawner.SpawnDrop(1, GlobalPosition, 1, 3, true); // TODO: remove magic numbers
            base.OnHealthDeath();
        }
    }
}