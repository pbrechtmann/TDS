using Godot;
using System;

public class WeaponAttachment : Weapon
{
    public enum TYPE { GENERAL, MELEE, RANGED }

    [Export] TYPE type = TYPE.GENERAL;

    public Weapon weapon;


    public void Init(Entity user, float dps, bool newWeapon)
    {
        this.user = user;
    }
}
