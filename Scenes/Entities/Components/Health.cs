using Godot;
using System;

public class Health : Node
{
    [Export]
    public float MaxHealth = 100;

    public bool Invincible = false;

    public float CurrentHealth;

    [Signal]
    public delegate void Death();
    [Signal]
    public delegate void MaxChanged(float newMax);


    public override void _Ready()
    {
        CurrentHealth = MaxHealth;
    }


    public void Regenerate(float changePerFrame)
    {
        CurrentHealth = Mathf.Clamp(CurrentHealth + changePerFrame, 0, MaxHealth);
    }


    public void Damage(float amount)
    {
        if (Invincible) return;
        CurrentHealth -= amount;
        if (CurrentHealth <= 0)
        {
            EmitSignal("Death");
        }
    }


    public void Heal(float amount)
    {
        CurrentHealth = Mathf.Clamp(CurrentHealth + amount, 0, MaxHealth);
    }


    public void ModifyValue(float modifier)
    {
        MaxHealth += modifier;
        EmitSignal("MaxChanged", MaxHealth);
    }


    public void ModifyPercent(float modifier)
    {
        float change = MaxHealth * (modifier / 100);
        MaxHealth += change;
        EmitSignal("MaxChanged", MaxHealth);
    }
}
