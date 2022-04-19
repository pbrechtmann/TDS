using Godot;
using System;

public class EnergySupply : Node
{
    [Export]
    public float MaxEnergy = 100;

    [Signal]
    public delegate void MaxChanged(float newMax);

    public float CurrentEnergy;

    public override void _Ready()
    {
        CurrentEnergy = MaxEnergy;
    }

    public void Regenerate(float changePerFrame)
    {
        CurrentEnergy = Mathf.Clamp(CurrentEnergy + changePerFrame, 0, MaxEnergy);
    }


    public bool Drain(float amount)
    {
        if (amount > CurrentEnergy)
        {
            return false;
        }
        CurrentEnergy -= amount;
        return true;
    }


    public void Charge(float amount)
    {
        CurrentEnergy = Mathf.Clamp(CurrentEnergy + amount, 0, MaxEnergy);
    }


    public float GetEnergyPercent()
    {
        return Mathf.Clamp(Mathf.InverseLerp(0, MaxEnergy, CurrentEnergy), 0, 1);
    }


    public void ModifyValue(float modifier)
    {
        MaxEnergy += modifier;
        EmitSignal("MaxChanged", MaxEnergy);
    }


    public void ModifyPercent(float modifier)
    {
        float change = MaxEnergy * (modifier / 100);
        MaxEnergy += change;
        EmitSignal("MaxChanged", MaxEnergy);
    }
}

