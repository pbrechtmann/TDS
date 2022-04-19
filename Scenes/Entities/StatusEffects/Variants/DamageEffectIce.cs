using Godot;
using System;

public class DamageEffectIce : DamageEffect
{
    private void StartEffects()
    {
        Target.ActionLock.AddActionLock();
        Target.ActionLock.AddMoveLock();
    }

    private void ClearEffects()
    {
        Target.ActionLock.RemoveActionLock();
        Target.ActionLock.RemoveMoveLock();
    }
}
