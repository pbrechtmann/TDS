using Godot;
using Godot.Collections;

public class DropSpawner : Node2D
{
    [Export] private PackedScene _autoDropScene;
    [Export] private PackedScene _itemDropScene;
    [Export] private PackedScene _upgradeDropScene;


    public void SpawnDrop(int tier, Vector2 position, int minDrops, int maxDrops, bool randomOffset = false)
    {
        int dropsAmount = (int)GD.RandRange(minDrops, maxDrops + 1);

        for (int i = 0; i < dropsAmount; i++)
        {
            Dictionary dropDict = new Dictionary();
            switch (tier)
            {
                case 1:
                    dropDict = LootData.Tier1[GD.Randi() % LootData.Tier1.size()];
                    break;
                case 2:
                    dropDict = LootData.Tier2[GD.Randi() % LootData.Tier2.size()];
                    break;
                case 3:
                    dropDict = LootData.Tier3[GD.Randi() % LootData.Tier3.size()];
                    break;
                case 4:
                    dropDict = LootData.Tier4[GD.Randi() % LootData.Tier4.size()];
                    break;
            }

            if (randomOffset)
            {
                position += new Vector2(GD.Randf(), GD.Randf()).Normalized() * (float)GD.RandRange(32, 64); // TODO: remove magic numbers
            }

            switch (dropDict["drop_type"])
            {
                case "auto":
                    SpawnAutoDrop((int)dropDict["attribute"], (int)dropDict["type"], (float)dropDict["value"], position);
                    break;
                case "item":
                    SpawnItemDrop((PackedScene)dropDict["scene"], (int)dropDict["type"], (Texture)dropDict["texture"], position);
                    break;
                case "upgrade":
                    SpawnUpgradeDrop((PackedScene)dropDict["scene"], (int)dropDict["type"], (Texture)dropDict["texture"], position);
                    break;
            }
        }
    }


    public void SpawnItemDrop(PackedScene item, int itemType, Texture texture, Vector2 position)
    {
        ItemDrop drop = _itemDropScene.Instance() as ItemDrop;

        drop.GlobalPosition = position;
        drop.Init(item, itemType, texture);
        CallDeferred("AddChild", drop);
    }

    public void SpawnUpgradeDrop(PackedScene upgrade, int upgradeType, Texture texture, Vector2 position)
    {
        UpgradeDrop drop = _upgradeDropScene.Instance() as UpgradeDrop;

        drop.GlobalPosition = position;
        drop.Init(upgrade, upgradeType, texture);
        CallDeferred("AddChild", drop);
    }


    public void SpawnAutoDrop(int attribute, int variant, float value, Vector2 position)
    {
        AutoDrop drop = _autoDropScene.Instance() as AutoDrop;

        drop.GlobalPosition = position;
        drop.Init(attribute, variant, value);
        CallDeferred("AddChild", drop);
    }


    public void Clear()
    {
        foreach (Node c in GetChildren())
        {
            c.QueueFree();
        }
    }
}
