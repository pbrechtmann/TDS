using Godot;
using System;

public class Ability : Node2D
{
    [Export] public Texture icon;
    [Export] public Texture dropIcon;

    [Export] public float cost;
    [Export] public float cooldown;
    [Export] public float duration;

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
        if (_ready && _user.energySupply.Drain(cost))
        {
            TryActivateAbility(user);
            _ready = false;
            if (duration > 0)
            {
                _durationTimer.Start(duration);
            }
            else
            {
                OnDurationTimeout();
            }
        }
    }


    private void ActivateAbility(Entity user)
    {
        if (duration > 0)
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
        _cooldownTimer.Start(cooldown);
    }


    public void OnCooldownTimeout()
    {
        _ready = true;
    }
}
