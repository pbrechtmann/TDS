using Godot;
using Godot.Collections;

public class StatMods : Node
{
    public float Speed = 1;
    public float SpeedDefault = 1;

    public float HealthChangePerSecond = 0;
    public float HealthChangePerSecondDefault = 0;

    public float EnergyChangePerSecond = 10;
    public float EnergyChangePerSecondDefault = 10;

    public Dictionary AttackMods;
    public Dictionary AttackModsDefault;

    public override void _Ready()
    {
        AttackMods.Add("damage", 1.0);
        AttackMods.Add("lifesteal", 0.0);

        AttackModsDefault.Add("damage", 1.0);
        AttackModsDefault.Add("lifesteal", 0.0);
    }


    public void SetDamage(float to) {
        AttackMods["damage"] = to;
    }

    public void SetDamageDefault(float to) {
        if (AttackMods["damage"] == AttackModsDefault["damage"]) {
            SetDamage(to);
        }
        AttackModsDefault["damage"] = to;
    }

    public void ResetDamage() {
        AttackMods["damage"] = AttackModsDefault["damage"];
    }


    public void SetLifesteal(float to) {
        AttackMods["lifesteal"] = to;
    }


    public void SetLifestealDefault(float to) {
        if (AttackMods["lifesteal"] == AttackModsDefault["lifesteal"]) {
            SetLifesteal(to);
        }
        AttackModsDefault["lifesteal"] = to;
    }


    public void ResetLifesteal() {
        AttackMods["lifesteal"] = AttackModsDefault["lifesteal"];
    }


    public void SetSpeed(float to) {
        Speed = to;
    }


    public void SetSpeedDefault(float to) {
        if (Speed == SpeedDefault) {
            SetSpeed(to);
        }
        SpeedDefault = to;
    }


    public void ResetSpeed() {
        Speed = SpeedDefault;
    }


    public void SetHealthChange(float to) {
        HealthChangePerSecond = to;
    }


    public void SetHealthChangeDefault(float to) {
        HealthChangePerSecondDefault = to;
    }


    public void ResetHealthChange() {
        HealthChangePerSecond = HealthChangePerSecondDefault;
    }


    public void SetEnergyChange(float to) {
        EnergyChangePerSecond = to;
    }


    public void SetEnergyChangeDefault(float to) {
        if (EnergyChangePerSecond == EnergyChangePerSecondDefault) {
            SetEnergyChange(to);
        }
        EnergyChangePerSecondDefault = to;
    }


    public void ResetEnergyChange() {
        EnergyChangePerSecond = EnergyChangePerSecondDefault;
    }
}
