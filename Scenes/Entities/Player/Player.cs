using Godot;
using System;

public class Player : Entity
{
    private Node2D _rangedContainer;
    private Node2D _meleeContainer;

    public WeaponRanged WeaponRanged;
    public WeaponMelee WeaponMelee;

    private Node2D _abilityContainer;
    private Node2D _abilityCharacterContainer;

    public Ability Ability;
    public Ability AbilityCharacter;

    public Weapon weapon;

    private DropSpawner dropSpawner;


    [Signal]
    public delegate void AbilityChanged();

    [Signal]
    public delegate void WeaponChanged();

    [Signal]
    public delegate void WeaponSwitched();

    [Signal]
    public delegate void GameOver();

    [Signal]
    public delegate void Pause();


    public override void _Ready()
    {
        _rangedContainer = GetNode<Node2D>("Weapons/Ranged");
        _meleeContainer = GetNode<Node2D>("Weapons/Melee");

        _abilityContainer = GetNode<Node2D>("Abilities/Ability");
        _abilityCharacterContainer = GetNode<Node2D>("Abilities/CharacterAbility");

        Ability = _abilityContainer.GetChild<Ability>(0);
        AbilityCharacter = _abilityCharacterContainer.GetChild<Ability>(0);

        WeaponRanged = _rangedContainer.GetChild<WeaponRanged>(0);
        WeaponMelee = _meleeContainer.GetChild<WeaponMelee>(0);

        WeaponRanged.Init(this, 0, false);
        WeaponMelee.Init(this, 0, false);

        weapon = WeaponRanged;

        // TODO: Attachments
    }


    public void Init(DropSpawner dropSpawner)
    {
        this.dropSpawner = dropSpawner;
    }


    private void Move()
    {
        Vector2 move = Vector2.Zero;
        if (Input.IsActionPressed("right")) move.x++;
        if (Input.IsActionPressed("left")) move.x--;
        if (Input.IsActionPressed("down")) move.y++;
        if (Input.IsActionPressed("up")) move.y--;

        move = MoveAndSlide(move.Normalized() * Speed * StatMods.Speed);
    }


    public override void _PhysicsProcess(float delta)
    {
        if (ActionLock.IsMoveLocked()) return;
        Move();
        LookAt(GetGlobalMousePosition());
    }


    public override void _Process(float delta)
    {
        if (ActionLock.IsActionLocked()) return;

        if (Input.IsActionPressed("attack_primary"))
        {
            weapon.TryPrimaryAttack(EnergySupply);
        }
    }


    public override void _UnhandledInput(InputEvent @event)
    {
        if (@event.IsActionPressed("pause"))
        {
            EmitSignal("pause");
        }

        if (ActionLock.IsActionLocked()) return;

        if (@event.IsActionPressed("attack_secondary"))
        {
            weapon.TrySecondaryAttack(EnergySupply);
        }
        if (@event.IsActionPressed("ability"))
        {
            Ability.TryActivateAbility(this);
        }
        if (@event.IsActionPressed("ability_character"))
        {
            AbilityCharacter.TryActivateAbility(this);
        }
        if (@event.IsActionPressed("interact"))
        {
            GD.PrintErr("Interact is not yet implemented.");
        }

        if (@event.IsActionPressed("weapon_hotkey_1"))
        {
            SwitchToRanged();
        }
        if (@event.IsActionPressed("weapon_hotkey_2"))
        {
            SwitchToMelee();
        }
    }


    private void SwitchToMelee()
    {
        weapon = WeaponMelee;
        EmitSignal("WeaponSwitched", "melee");
    }


    private void SwitchToRanged()
    {
        weapon = WeaponRanged;
        EmitSignal("WeaponSwitched", "ranged");
    }


    private void SwitchWeapon()
    {
        if (weapon == WeaponRanged)
        {
            weapon = WeaponMelee;
        }
        else
        {
            weapon = WeaponRanged;
        }
    }

    public void SetActive(bool active)
    {
        SetPhysicsProcess(active);
        SetProcess(active);
        SetProcessUnhandledInput(active);
    }


    public void PickupWeapon(PackedScene scene)
    {
        // TODO
        GD.PrintErr("Not yet implemented.");
        Weapon newWeapon = scene.Instance() as Weapon;
        PackedScene packed = new PackedScene();
        if (newWeapon is WeaponMelee)
        {
            if (packed.Pack(WeaponMelee) != Error.Ok)
            {
                GD.PrintErr("Packing melee weapon failed.");
                return;
            }

            dropSpawner.SpawnItemDrop(packed, ItemDrop.ITEM_TYPE.WEAPON, WeaponMelee.Icon, _meleeContainer.GlobalPosition);

            WeaponMelee oldWeapon = WeaponMelee;
            WeaponMelee = (WeaponMelee)newWeapon;
            _meleeContainer.AddChild(WeaponMelee);

            WeaponMelee.Init(this, Mathf.Max(oldWeapon.GetDPS(), WeaponRanged.GetDPS()), newWeapon.NewWeapon);

            oldWeapon.QueueFree();

            SwitchToMelee();
            EmitSignal("WeaponChanged");
        }
        else if (newWeapon is WeaponRanged)
        {
            if (packed.Pack(WeaponRanged) != Error.Ok)
            {
                GD.PrintErr("Packing ranged weapon failed.");
                return;
            }

            dropSpawner.SpawnItemDrop(packed, ItemDrop.ITEM_TYPE.WEAPON, WeaponRanged.Icon, _rangedContainer.GlobalPosition);

            WeaponRanged oldWeapon = WeaponRanged;
            WeaponRanged = (WeaponRanged)newWeapon;
            _rangedContainer.AddChild(WeaponRanged);

            WeaponRanged.Init(this, Mathf.Max(oldWeapon.GetDPS(), WeaponMelee.GetDPS()), newWeapon.NewWeapon);

            oldWeapon.QueueFree();

            SwitchToRanged();
            EmitSignal("WeaponChanged");
        }
    }

    public void PickupAbility(PackedScene scene)
    {
        Ability newAbility = scene.Instance() as Ability;
        Ability oldAbility = null;

        if (Ability != null)
        {
            PackedScene packed = new PackedScene();
            if (packed.Pack(Ability) != Error.Ok)
            {
                GD.PrintErr("Packing ability failed.");
                return;
            }

            dropSpawner.SpawnItemDrop(packed, ItemDrop.ITEM_TYPE.ABILITY, oldAbility.Icon, GlobalPosition);

            oldAbility = Ability;
        }

        _abilityContainer.AddChild(newAbility);
        Ability = newAbility;

        if (oldAbility != null)
        {
            oldAbility.QueueFree();
        }

        EmitSignal("AbilityChanged");
    }


    public new void OnHealthDeath()
    {
        EmitSignal("GameOver");
        base.OnHealthDeath();
    }
}


