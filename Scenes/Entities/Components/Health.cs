using Godot;
using System;

public class Health : Node
{
    [Export]
    public float MaxHealth = 100;

    public bool Invincible = false;
    
    private float _currentHealth;

    [Signal]
    public delegate void Death();
    [Signal]
    public delegate void MaxChanged(float newMax);


    public override void _Ready()
    {
        _currentHealth = MaxHealth;
    }


    public void Regenerate(float changePerFrame) {
        _currentHealth = Mathf.Clamp(_currentHealth + changePerFrame, 0, MaxHealth);
    }


    public void Damage(float amount) {
        if (Invincible) return;
        _currentHealth -= amount;
        if (_currentHealth <= 0) {
            EmitSignal("Death");
        }
    }


    public void Heal(float amount) {
        _currentHealth = Mathf.Clamp(_currentHealth + amount, 0, MaxHealth);
    }


    public void ModifyValue(float modifier) {
        MaxHealth += modifier;
        EmitSignal("MaxChanged", MaxHealth);
    }


    public void ModifyPercent(float modifier) {
        float change = MaxHealth * (modifier / 100);
        MaxHealth += change;
        EmitSignal("MaxChanged", MaxHealth);
    }
}
