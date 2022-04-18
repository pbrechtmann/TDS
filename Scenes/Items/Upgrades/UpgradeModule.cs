using Godot;
using System;

public class UpgradeModule : Node
{
    protected bool valid = true;

    public void Init(Node2D target)
    {
        target.AddChild(this);
        this.Owner = target;
        ApplyUpgrade(target);
    }


    public void ApplyUpgrade(Node2D to)
    {

    }
}