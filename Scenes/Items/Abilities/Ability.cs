using Godot;
using System;

public class Ability : Node2D
{
    [Export] public Texture Icon;
    [Export] public Texture DropIcon;

    [Export] public float Cost;
    [Export] public float Cooldown;
    [Export] public float Duration;

    private bool _ready = true;
    private Entity _user;

    private Timer _cooldownTimer;
    private Timer _durationTimer;

    public override void _Ready()
    {
        _cooldownTimer = GetNode<Timer>("Cooldown");
        _durationTimer = GetNode<Timer>("Duration");
        SetProcess(false);
    }


    public void TryActivateAbility(Entity user)
    {
        _user = user;
        if (_ready && _user.EnergySupply.Drain(Cost))
        {
            TryActivateAbility(user);
            _ready = false;
            if (Duration > 0)
            {
                _durationTimer.Start(Duration);
            }
            else
            {
                OnDurationTimeout();
            }
        }
    }


    private void ActivateAbility(Entity user)
    {
        if (Duration > 0)
        {
            SetProcess(true);
        }
    }


    private void EndAbility() { }


    public override void _Process(float delta)
    {
        CustomProcess(delta);
    }

    private void CustomProcess(float delta) { }


    public void OnDurationTimeout()
    {
        SetProcess(false);
        EndAbility();
        _cooldownTimer.Start(Cooldown);
    }


    public void OnCooldownTimeout()
    {
        _ready = true;
    }
}
