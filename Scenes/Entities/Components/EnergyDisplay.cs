using Godot;
using System;

public class EnergyDisplay : Sprite
{
    private ShaderMaterial _display_material;
    public override void _Ready()
    {
        _display_material = ResourceLoader.Load("res://Assets/Shaders/EnergyDisplay.material").Duplicate() as ShaderMaterial;
        Material = _display_material;
    }


    public void ShowEnergy(EnergySupply energySupply) {
        _display_material.SetShaderParam("fill_ratio", energySupply.GetEnergyPercent());
    }
}
