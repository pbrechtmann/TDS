using Godot;
using System;

public class WeaponAttachment : Weapon
{
    public enum TYPE { GENERAL, MELEE, RANGED }

    [Export] public TYPE type = TYPE.GENERAL;

    public Weapon Weapon;


    public void Init(Entity user, float dps, bool newWeapon)
    {
        this.User = user;
    }
}
