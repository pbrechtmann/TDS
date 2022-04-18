using Godot;
using System;

public class InteractableObject : Node2D
{
    private ShaderMaterial _highlight;
    protected Sprite Sprite;
    public override void _Ready()
    {
        _highlight = ResourceLoader.Load<ShaderMaterial>("res://Assets/Shaders/DropHighlight.material");
        Sprite = GetNode<Sprite>("Sprite");
    }

    public void Activate(Entity user) { }

    public void Highlight()
    {
        Sprite.Material = _highlight;
    }


    public void ClearHighlight()
    {
        Sprite.Material = null;
    }
}