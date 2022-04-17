using Godot;
using System;

public class Weapon : Node2D
{
    private Timer _cooldown;
    private Node2D _attachmentContainer;


    [Export] public Texture icon;
    [Export] public Texture dropIcon;

    [Export] public float cooldown = 0.5f;
    [Export] public float cost = 25;

    //TODO: Modifiers

    [Export] public bool newWeapon = true;

    private bool _ready = true;
    public Entity user;

    private WeaponAttachment _attachment = null;
    public override void _Ready()
    {
        _cooldown = GetNode<Timer>("Cooldown");
        _attachmentContainer = GetNode<Node2D>("AttachmentContainer");
    }


    public void Init(Entity user, float dps, bool newWeapon)
    {
        this.user = user;
        if (newWeapon)
        {
            // TODO: damage = NewDPS(dps);
        }

        this.newWeapon = false;
        FindAttachment();
    }


    public void TryPrimaryAttack(EnergySupply energySupply)
    {
        if (_ready && energySupply.Drain(cost))
        {
            PrimaryAttack();

            _ready = false;
            _cooldown.Start(cooldown);
        }
    }


    private void PrimaryAttack() { }


    public void TrySecondaryAttack(EnergySupply energySupply)
    {
        // TODO
    }


    public void Attach(PackedScene attachmentScene)
    {
        _attachment = attachmentScene.Instance() as WeaponAttachment;
        _attachmentContainer.AddChild(_attachment);
        _attachment.Owner = this;
        _attachment.Init(user, GetDPS(), true);
        _attachment.weapon = this;
    }


    private void FindAttachment()
    {
        if (_attachmentContainer.GetChildCount() == 1)
        {
            _attachment = _attachmentContainer.GetChild<WeaponAttachment>(0);
            _attachment.Init(user, 0, false);
            _attachment.weapon = this;
        }
    }

    public float GetDPS()
    {
        float shotsPerSecond = 1.0f / cooldown;
        return shotsPerSecond; // TODO : multiply with damage
    }


    private float NewDPS(float baseDPS)
    {
        float shotsPerSecond = 1.0f / cooldown;
        float baseDamage = baseDPS / shotsPerSecond;
        return baseDamage + (float)GD.RandRange(-baseDamage * 0.4, baseDamage * 0.1); // TODO: remove magic numbers
    }


    public void OnCooldownTimeout()
    {
        _ready = true;
    }
}
