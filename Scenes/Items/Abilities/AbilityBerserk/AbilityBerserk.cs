using Godot;
using System;

public class AbilityBerserk : Ability
{
    [Export]
    private float _damageMultiplier = 3.0f;
    [Export]
    private float _speedMultiplier = 1.2f;
    [Export]
    private float _damageTakenPerSecond = 1.0f;

    private new void ActivateAbility(Entity user)
    {
        base.ActivateAbility(user);
        user.StatMods.SetDamage(_damageMultiplier);
        user.StatMods.SetSpeed(_speedMultiplier);
        user.StatMods.SetHealthChange(-_damageTakenPerSecond);
    }


    private void EndAbility()
    {
        User.StatMods.ResetDamage();
        User.StatMods.ResetSpeed();
        User.StatMods.ResetHealthChange();
    }
}
