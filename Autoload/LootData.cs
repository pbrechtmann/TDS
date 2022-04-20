using Godot;
using Godot.Collections;
using System;

public class LootData : Node
{
    private const String _lootFilePath = "res://Data/loot.json";

    public static Godot.Collections.Array Tier1;
    public static Godot.Collections.Array Tier2;
    public static Godot.Collections.Array Tier3;
    public static Godot.Collections.Array Tier4;



    public LootData()
    {
        Dictionary lootData = LoadFileData(_lootFilePath);

        GD.Print(lootData.GetType());

        foreach (Dictionary item in lootData)
        {
            Dictionary itemData = (Dictionary)lootData[item];
            foreach (String key in itemData)
            {
                switch (key)
                {
                    case "attribute":
                        itemData[key] = (int)itemData[key];
                        break;
                    case "drop_type":
                        // ignored, no parse needed.
                        break;
                    case "scene":
                        itemData[key] = ResourceLoader.Load((String)itemData[key]);
                        break;
                    case "texture":
                        itemData[key] = ResourceLoader.Load((String)itemData[key]);
                        break;
                    case "tier":
                        itemData[key] = (int)itemData[key];
                        break;
                    case "type":
                        itemData[key] = (int)itemData[key];
                        break;
                    case "value":
                        itemData[key] = (float)itemData[key];
                        break;
                }
            }

            switch (itemData["tier"])
            {
                case 1:
                    itemData.Remove("tier");
                    Tier1.Add(lootData["item"]);
                    break;
                case 2:
                    itemData.Remove("tier");
                    Tier2.Add(lootData["item"]);
                    break;
                case 3:
                    itemData.Remove("tier");
                    Tier3.Add(lootData["item"]);
                    break;
                case 4:
                    itemData.Remove("tier");
                    Tier4.Add(lootData["item"]);
                    break;
            }
        }
    }

    private Dictionary LoadFileData(String filePath)
    {
        File dataFile = new File();
        dataFile.Open(filePath, File.ModeFlags.Read);

        JSONParseResult dataJSON = JSON.Parse(dataFile.GetAsText());
        dataFile.Close();

        Dictionary result = (Dictionary)dataJSON.Result;
        return result;
    }
}
