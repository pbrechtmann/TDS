using Godot;
using System;

public class HealthDisplay : Node
{
    private TextureProgress _healthBar;

    public override void _Ready()
    {
        _healthBar = GetNode<TextureProgress>("HealthBar");
    }


    public void ShowHealth(Health health)
    {
        _healthBar.Value = health.CurrentHealth / health.MaxHealth * 100;
    }
}
