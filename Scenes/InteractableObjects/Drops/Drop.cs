using Godot;
using System;

public class Drop : InteractableObject
{
    protected Texture DropTexture;

    public override void _Ready()
    {
        if (DropTexture != null)
        {
            Sprite.Texture = DropTexture;
        }
    }

    public new void Activate(Entity user)
    {
        QueueFree();
    }
}
