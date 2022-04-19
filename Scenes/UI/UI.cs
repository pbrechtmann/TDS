using Godot;
using System;

public class UI : CanvasLayer
{
    private Player _player;

    private MarginContainer _marginContainer;

    private TextureProgress _energyBar;
    private TextureProgress _healthBar;

    private TextureProgress _abilityCooldown;
    private TextureProgress _abilityCharacterCooldown;

    private TextureRect _meleeDisplay;
    private TextureRect _rangedDisplay;

    public override void _Ready()
    {
        _marginContainer = GetNode<MarginContainer>("Control/MarginContontainer");

        _energyBar = GetNode<TextureProgress>("Control/MarginContainer/HBoxContainer/VBoxContainer/Energy");
        _healthBar = GetNode<TextureProgress>("Control/MarginContainer/HBoxContainer/VBoxContainer/Health");

        _abilityCooldown = GetNode<TextureProgress>("Control/MarginContainer/HBoxContainer/Ability");
        _abilityCharacterCooldown = GetNode<TextureProgress>("Control/MarginContainer/HBoxContainer/AbilityCharacter");

        _meleeDisplay = GetNode<TextureRect>("Control/MarginContainer/HBoxContainer/WeaponMelee/Display");
        _rangedDisplay = GetNode<TextureRect>("Control/MarginContainer/HBoxContainer/WeaponRanged/Display");


        Vector2 windowSize = OS.WindowSize;
        _marginContainer.MarginBottom = windowSize.y / -108f;
        _marginContainer.MarginTop = windowSize.y - 128 + _marginContainer.MarginBottom;
        _marginContainer.MarginLeft = (windowSize.x / 192f) * 2;
        _marginContainer.MarginRight = -_marginContainer.MarginLeft;
    }


    public void Init(Player player)
    {
        _player = player;

        if (_player.Health.Connect("MaxChanged", this, "OnHealthMaxChanged") != Error.Ok)
        {
            GD.PrintErr("Connecting max changed from Health to UI failed");
        }
        if (_player.EnergySupply.Connect("MaxChanged", this, "OnEnergyMaxChanged") != Error.Ok)
        {
            GD.PrintErr("Connecting max changed from EnergySupply to UI failed");
        }
        if (_player.Connect("AbilityChanged", this, "OnPlayerAbilityChanged") != Error.Ok)
        {
            GD.PrintErr("Connecting ability changed from Player to UI failed");
        }
        if (_player.Connect("WeaponChanged", this, "OnPlayerWeaponChanged") != Error.Ok)
        {
            GD.PrintErr("Connecting weapon changed from Player to UI failed");
        }
        if (_player.Connect("WeaponSwitched", this, "OnPlayerWeaponSwitched") != Error.Ok)
        {
            GD.PrintErr("Connecting weapon switched from Player to UI failed");
        }

        _healthBar.MaxValue = _player.Health.MaxHealth;
        _energyBar.MaxValue = _player.EnergySupply.MaxEnergy;

        _abilityCooldown.MaxValue = _player.Ability.Cooldown;
        _abilityCooldown.TextureProgress_ = _player.Ability.Icon;

        _abilityCharacterCooldown.MaxValue = _player.AbilityCharacter.Cooldown;
        _abilityCharacterCooldown.TextureProgress_ = _player.AbilityCharacter.Icon;

        _meleeDisplay.Texture = _player.WeaponMelee.Icon;
        _rangedDisplay.Texture = _player.WeaponRanged.Icon;
    }


    public override void _Process(float delta)
    {
        if (!IsInstanceValid(_player)) return;

        _healthBar.Value = _player.Health.CurrentHealth;
        _energyBar.Value = _player.EnergySupply.CurrentEnergy;

        if (!_player.Ability.CooldownTimer.IsStopped())
        {
            _abilityCooldown.Value = 0;
        }
        else
        {
            _abilityCooldown.Value = _abilityCooldown.MaxValue - _player.Ability.CooldownTimer.TimeLeft;
        }

        if (!_player.AbilityCharacter.CooldownTimer.IsStopped())
        {
            _abilityCharacterCooldown.Value = 0;
        }
        else
        {
            _abilityCharacterCooldown.Value = _abilityCharacterCooldown.MaxValue - _player.AbilityCharacter.CooldownTimer.TimeLeft;
        }
    }


    public void OnHealthMaxChanged(float newValue)
    {
        _healthBar.MaxValue = newValue;
    }


    public void OnEnergyMaxChanged(float newValue)
    {
        _energyBar.MaxValue = newValue;
    }


    public void OnAbilityCooldownChanged(float newValue)
    {
        _abilityCooldown.MaxValue = newValue;
    }


    public void OnAbilityCharacterCooldownChanged(float newValue)
    {
        _abilityCharacterCooldown.MaxValue = newValue;
    }


    public void OnPlayerAbilityChanged()
    {
        _abilityCooldown.TextureProgress_ = _player.Ability.Icon;

        OnAbilityCooldownChanged(_player.Ability.Cooldown);
    }


    public void OnPlayerWeaponChanged()
    {
        _meleeDisplay.Texture = _player.WeaponMelee.Icon;
        _rangedDisplay.Texture = _player.WeaponRanged.Icon;
    }


    public void OnPlayerWeaponSwitched(String switchedTo)
    {
        if (switchedTo == "melee")
        {
            // TODO: Frame current weapon
        }
        else
        {

        }
    }
}
