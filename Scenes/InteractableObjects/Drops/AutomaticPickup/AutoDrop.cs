using Godot;
using System;

public class AutoDrop : Drop
{
    public enum ATTRIBUTE { ENERGY, HEALTH }
    public enum TYPE { PERCENTAGE, VALUE }

    private Entity _target;
    private float _speed = 10;

    private float _statRestore;
    private ATTRIBUTE _attribute;
    private TYPE _type;


    public override void _Ready()
    {
        SetProcess(false);
    }


    public void Init(ATTRIBUTE attribute, TYPE type, float value)
    {
        _attribute = attribute;
        _type = type;
        _statRestore = value;
    }


    public new void Activate(Entity user)
    {
        switch (_attribute)
        {
            case ATTRIBUTE.ENERGY:
                switch (_type)
                {
                    case TYPE.PERCENTAGE:
                        user.EnergySupply.Charge(user.EnergySupply.MaxEnergy * _statRestore);
                        break;
                    case TYPE.VALUE:
                        user.EnergySupply.Charge(_statRestore);
                        break;
                }
                break;
            case ATTRIBUTE.HEALTH:
                switch (_type)
                {
                    case TYPE.PERCENTAGE:
                        user.Health.Heal(user.Health.MaxHealth * _statRestore);
                        break;
                    case TYPE.VALUE:
                        user.Health.Heal(_statRestore);
                        break;
                }
                break;
        }
        base.Activate(user);
    }


    public void Start(Entity target)
    {
        _target = target;
        SetProcess(true);
    }


    public override void _Process(float delta)
    {
        if (IsInstanceValid(_target))
        {
            GlobalPosition += GlobalPosition.DirectionTo(_target.GlobalPosition) * _speed;
        }
    }


    public void OnAutoDropBodyEntered(PhysicsBody2D body)
    {
        if (body == _target)
        {
            Activate(_target);
        }
    }
}