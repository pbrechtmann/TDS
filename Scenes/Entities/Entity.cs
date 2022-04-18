using Godot;
using Godot.Collections;

public class Entity : KinematicBody2D
{
    [Export]
    public PackedScene EffectDamageBleeding;
    [Export]
    public PackedScene EffectDamageFire;
    [Export]
    public PackedScene EffectDamageIce;
    [Export]
    public PackedScene EffectDamagePoison;

    [Export]
    protected float Speed;

    public Armor Armor;
    public Health Health;
    public EnergySupply EnergySupply;
    private EnergyDisplay _energyDisplay;
    public StatMods StatMods;
    public ActionLock ActionLock;

    public override void _Ready()
    {
        Armor = GetNode<Armor>("Armor");
        Health = GetNode<Health>("Health");
        EnergySupply = GetNode<EnergySupply>("EnergySupply");
        _energyDisplay = GetNode<EnergyDisplay>("EnergyDisplay");
        StatMods = GetNode<StatMods>("StatMods");
        ActionLock = GetNode<ActionLock>("ActionLock");

        if (Health.Connect("Death", this, "OnHealthDeath") != Error.Ok)
        {
            GD.PrintErr("Health couldn't connect signal Death to Entity.");
        }
    }


    public override void _Process(float delta)
    {
        Health.Regenerate(StatMods.HealthChangePerSecond * delta);
        EnergySupply.Regenerate(StatMods.EnergyChangePerSecond * delta);

        _energyDisplay.ShowEnergy(EnergySupply);
    }


    public void GetDamage(Dictionary modifiers, Entity source)
    { // TODO rework damage system
        modifiers = Armor.Modify(modifiers);

        float damage = 0;
        float critChance = 0;
        float critMultiplier = 1;

        if (modifiers.Contains("damage"))
        {
            damage = (float)modifiers["damage"];
        }

        if (modifiers.Contains("crit_chance"))
        {
            critChance = (float)modifiers["crit_chance"];
        }

        if (modifiers.Contains("crit_multiplier"))
        {
            critMultiplier = (float)modifiers["crit_multiplier"];
        }

        if (GD.RandRange(0, 1) < critChance)
        {
            damage *= critMultiplier;
        }

        // TODO: Add effects
        Health.Damage(damage);
    }


    private void AddEffect(Dictionary modifiers, PackedScene scene)
    {
        DamageEffect effect = scene.Instance() as DamageEffect;
        AddChild(effect);
        effect.Init(this, modifiers);
    }


    public void OnHealthDeath()
    {
        QueueFree();
    }
}
