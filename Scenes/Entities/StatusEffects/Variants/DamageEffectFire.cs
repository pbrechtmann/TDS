using Godot;
using System;

public class DamageEffectFire : DamageEffect
{
    private void CustomProcess(float delta)
    {
        Target.Health.Damage(DamagePerSecond * delta);
    }
}
