using Godot;
using System;

public class DamageEffectPoison : DamageEffect
{
    private void CustomProcess(float delta)
    {
        Target.Health.ModifyValue(-DamagePerSecond * delta);
    }
}
