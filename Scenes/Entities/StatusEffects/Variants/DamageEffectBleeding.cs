using Godot;
using System;

public class DamageEffectBleeding : DamageEffect
{
    private void CustomProcess(float delta)
    {
        Target.Health.Damage(DamagePerSecond * delta);
    }
}
