using Godot;
using System;

public class UpgradeDrop : Drop
{
    public enum UPGRADE_TYPE { ABILITY, ARMOR, CHARACTER, WEAPON, WEAPON_MELEE, WEAPON_RANGED }

    [Export] private PackedScene scene;
    [Export] UPGRADE_TYPE type;

    public void Activate(Player user)
    {
        UpgradeModule upgrade = scene.Instance() as UpgradeModule;

        switch (type)
        {
            case UPGRADE_TYPE.ABILITY:
                if (user.Ability != null)
                {
                    upgrade.ApplyUpgrade(user.Ability);
                }
                else
                {
                    return;
                }
                break;
            case UPGRADE_TYPE.ARMOR:
                upgrade.ApplyUpgrade(user.Armor);
                break;
            case UPGRADE_TYPE.CHARACTER:
                upgrade.ApplyUpgrade(user);
                break;
            case UPGRADE_TYPE.WEAPON:
                upgrade.ApplyUpgrade(user.weapon);
                break;
            case UPGRADE_TYPE.WEAPON_MELEE:
                upgrade.ApplyUpgrade(user.WeaponMelee);
                break;
            case UPGRADE_TYPE.WEAPON_RANGED:
                upgrade.ApplyUpgrade(user.WeaponRanged);
                break;
        }

        base.Activate(user);
    }


    public void Init(PackedScene scene, UPGRADE_TYPE type, Texture texture)
    {
        this.scene = scene;
        this.type = type;
        DropTexture = texture;
    }
}
