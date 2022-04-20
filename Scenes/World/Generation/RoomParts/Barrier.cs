using Godot;

public class Barrier : StaticBody2D
{
    private Sprite _sprite;


    public override void _Ready()
    {
        _sprite = GetNode<Sprite>("Sprite");
    }

    public void SetActive(bool active)
    {
        CollisionLayer = (uint)(active ? 1 : 0);
        _sprite.Visible = active;
    }
}
