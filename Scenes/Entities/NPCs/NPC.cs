using Godot;
using System;

public class NPC : Entity
{
    protected Navigation2D Nav;
    protected Entity Target;
    protected DropSpawner DropSpawner;

    protected bool dead = false;

    public void Init(Navigation2D nav, Entity target, DropSpawner dropSpawner)
    {
        Nav = nav;
        Target = target;
        DropSpawner = dropSpawner;
    }
}
