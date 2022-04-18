using Godot;
using Godot.Collections;

public class WeaponMelee : Weapon
{
    [Export] public float Duration = 0.1f;

    private Area2D _area;
    private Tween _tween;

    private Vector2 _defaultPos = Vector2.Zero;
    private float _defaultRotation = 0;
    private Array _hits;
    public override void _Ready()
    {
        _area = GetNode<Area2D>("Area2D");
        _tween = GetNode<Tween>("Tween");

        _defaultPos += Position;
        _defaultRotation += RotationDegrees;

        SetProcess(false);
    }


    private void PrimaryAttack()
    {
        SetProcess(true);
    }


    private void AttackDone()
    {
        SetProcess(false);

        _hits.Clear();
    }


    public override void _Process(float delta)
    {
        Array targets = _area.GetOverlappingBodies();
        for (int i = 0; i < targets.Count; i++)
        {
            Entity target = null;
            if (targets[i] is Entity)
            {
                target = (Entity)targets[i];
            }
            if (target != null && target != User && !_hits.Contains(target))
            {
                _hits.Add(target);
                target.GetDamage(, User); // TODO
            }
        }
    }
}
