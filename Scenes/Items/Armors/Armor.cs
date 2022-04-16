using Godot;
using Godot.Collections;

public class Armor : Node2D
{
    [Export]
    public Dictionary BaseMultipliers;
    [Export]
    public int ResistancesDamage = 0;
    [Export]
    public int ResistancesFire = 0;
    [Export]
    public int ResistancesIce = 0;
    [Export]
    public int ResistancesPoison = 0;

    private Dictionary _multipliers;

    public override void _Ready()
    {
        _multipliers = BaseMultipliers.Duplicate(true);
    }


    public Dictionary Modify(Dictionary modifiers) {
        modifiers = modifiers.Duplicate(true);
        // TODO multiply with multipliers

        return modifiers;
    }
}
