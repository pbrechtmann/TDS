using Godot;
using Godot.Collections;

public class DamageEffect : Node2D
{
    private float _damagePerSecond;
    private Entity _target;
    private Timer _timer;


    public override void _Ready()
    {
        _timer = GetNode<Timer>("Duration");
        if (_timer.Connect("timeout", this, "OnDurrationTimeout") != Error.Ok) {
            GD.PrintErr("DamageEffect couldn't connect timeout signal");
        }
    }


    public void Init(Entity target, Dictionary effectInfo) {
        _target = target;
        _damagePerSecond = (float) effectInfo["dps"];

        target.Health.Damage((float) effectInfo["initial_damage"]);
        _timer.Start((float) effectInfo["duration"]);
        StartEffects();
    }


    public override void _Process(float delta)
    {
        CustomProcess(delta);
    }


    private void CustomProcess(float delta) {}


    private void StartEffects() {}


    private void ClearEffects() {}


    public void OnDurationTimeout() {
        ClearEffects();
        QueueFree();
    }
}