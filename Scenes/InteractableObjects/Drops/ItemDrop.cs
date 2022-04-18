using Godot;
using System;

public class ItemDrop : Drop
{
    public enum ITEM_TYPE { ABILITY, ARMOR, WEAPON }

    [Export] public PackedScene Scene;
    [Export] public ITEM_TYPE Type;


    public void Activate(Player user)
    {
        switch (Type)
        {
            case ITEM_TYPE.ABILITY:
                user.PickupAbility(Scene);
                break;
            case ITEM_TYPE.ARMOR:
                // TODO
                break;
            case ITEM_TYPE.WEAPON:
                user.PickupWeapon(Scene);
                break;
        }

        base.Activate(user);
    }


    public void Init(PackedScene scene, ITEM_TYPE type, Texture texture)
    {
        Scene = scene;
        Type = type;
        DropTexture = texture;
    }
}
