using Godot;
using System;

public class EnergySupply : Node
{
    [Export]
    public float MaxEnergy = 100;

    [Signal]
    public delegate void MaxChanged(float newMax);

    private float _currentEnergy;

    public override void _Ready() {
        _currentEnergy = MaxEnergy;
    }

    public void Regenerate(float changePerFrame) {
        _currentEnergy = Mathf.Clamp(_currentEnergy + changePerFrame, 0, MaxEnergy);
    }


    public bool Drain(float amount) {
        if (amount > _currentEnergy) {
            return false;
        }
        _currentEnergy -= amount;
        return true;
    }


    public void Charge(float amount) {
        _currentEnergy = Mathf.Clamp(_currentEnergy + amount, 0, MaxEnergy);
    }


    public float GetEnergyPercent() {
        return Mathf.Clamp(Mathf.InverseLerp(0, MaxEnergy, _currentEnergy), 0, 1);
    }


    public void ModifyValue(float modifier) {
        MaxEnergy += modifier;
        EmitSignal("MaxChanged", MaxEnergy);
    }


    public void ModifyPercent(float modifier) {
        float change = MaxEnergy * (modifier / 100);
        MaxEnergy += change;
        EmitSignal("MaxChanged", MaxEnergy);
    }
}

