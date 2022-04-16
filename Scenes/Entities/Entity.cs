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
    public float speed;

    private Armor _armor;
    public Health Health;
    public EnergySupply energySupply;
    private EnergyDisplay _energyDisplay;
    public StatMods statMods;
    public ActionLock actionLock;

    public override void _Ready()
    {
        _armor = GetNode<Armor>("Armor");
        Health = GetNode<Health>("Health");
        energySupply = GetNode<EnergySupply>("EnergySupply");
        _energyDisplay = GetNode<EnergyDisplay>("EnergyDisplay");
        statMods = GetNode<StatMods>("StatMods");
        actionLock = GetNode<ActionLock>("ActionLock");

        if (Health.Connect("Death", this, "OnHealthDeath") != Error.Ok) {
            GD.PrintErr("Health couldn't connect signal Death to Entity.");
        }
    }


    public override void _Process(float delta)
    {
        Health.Regenerate(statMods.HealthChangePerSecond * delta);
        energySupply.Regenerate(statMods.EnergyChangePerSecond * delta);

        _energyDisplay.ShowEnergy(energySupply);
    }


    public void GetDamage(Dictionary modifiers, Entity source) {
        modifiers = _armor.Modify(modifiers);

        float damage = 0;
        float critChance = 0;
        float critMultiplier = 1;

        if (modifiers.Contains("damage")) {
            damage = (float) modifiers["damage"];
        }

        if (modifiers.Contains("crit_chance")) {
            critChance = (float) modifiers["crit_chance"];
        }

        if (modifiers.Contains("crit_multiplier")) {
            critMultiplier = (float) modifiers["crit_multiplier"];
        }

        if (GD.RandRange(0, 1) < critChance) {
            damage *= critMultiplier;
        }

        // TODO: Add effects
        Health.Damage(damage);
    }


    private void AddEffect(Dictionary modifiers, PackedScene scene) {
        DamageEffect effect = scene.Instance() as DamageEffect;
        AddChild(effect);
        effect.Init(this, modifiers);
    }


    public void OnHealthDeath() {
        QueueFree();
    }
}
