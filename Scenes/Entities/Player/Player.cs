using Godot;
using System;

public class Player : Entity
{
    private Node2D _rangedContainer;
    private Node2D _meleeContainer;

    public WeaponRanged weaponRanged;
    public WeaponMelee weaponMelee;

    private Node2D _abilityContainer;
    private Node2D _abilityCharacterContainer;

    public Ability ability;
    public Ability abilityCharacter;

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

        ability = _abilityContainer.GetChild<Ability>(0);
        abilityCharacter = _abilityCharacterContainer.GetChild<Ability>(0);

        weaponRanged = _rangedContainer.GetChild(0);
        weaponMelee = _meleeContainer.GetChild(0);

        weaponRanged.Init(this, false, 0);
        weaponMelee.Init(this, false, 0);

        weapon = weaponRanged;

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

        move = MoveAndSlide(move.Normalized() * speed * statMods.Speed);
    }


    public override void _PhysicsProcess(float delta)
    {
        if (actionLock.IsMoveLocked()) return;
        Move();
        LookAt(GetGlobalMousePosition());
    }


    public override void _Process(float delta)
    {
        if (actionLock.IsActionLocked()) return;

        if (Input.IsActionPressed("attack_primary"))
        {
            weapon.TryPrimaryAttack(energySupply, statMods.AttackMods);
        }
    }


    public override void _UnhandledInput(InputEvent @event)
    {
        if (@event.IsActionPressed("pause"))
        {
            EmitSignal("pause");
        }

        if (actionLock.IsActionLocked()) return;

        if (@event.IsActionPressed("attack_secondary"))
        {
            weapon.TrySecondaryAttack(energySupply, statMods.AttackMods);
        }
        if (@event.IsActionPressed("ability"))
        {
            ability.TryActivateAbility(this);
        }
        if (@event.IsActionPressed("ability_character"))
        {
            abilityCharacter.TryActivateAbility(this);
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
        weapon = weaponMelee;
        EmitSignal("WeaponSwitched", "melee");
    }


    private void SwitchToRanged()
    {
        weapon = weaponRanged;
        EmitSignal("WeaponSwitched", "ranged");
    }


    private void SwitchWeapon()
    {
        if (weapon == weaponRanged)
        {
            weapon = weaponMelee;
        }
        else
        {
            weapon = weaponRanged;
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
            if (packed.Pack(weaponMelee) != Error.Ok)
            {
                GD.PrintErr("Packing melee weapon failed.");
                return;
            }



            SwitchToMelee();
            EmitSignal("WeaponChanged");
        }
        else if (newWeapon is WeaponRanged)
        {
            if (packed.Pack(weaponRanged) != Error.Ok)
            {
                GD.PrintErr("Packing ranged weapon failed.");
                return;
            }




            SwitchToRanged();
            EmitSignal("WeaponChanged");
        }
    }

    public void PickupAbility(PackedScene scene)
    {
        Ability newAbility = scene.Instance() as Ability;
        Ability oldAbility;

        if (ability != null)
        {
            PackedScene packed = new PackedScene();
            if (packed.Pack(ability) != Error.Ok)
            {
                GD.PrintErr("Packing ability failed.");
                return;
            }

            dropSpawner.SpawnItemDrop();

            oldAbility = ability;
        }

        _abilityContainer.AddChild(newAbility);
        ability = newAbility;

        if (oldAbility)
        {
            oldAbility.QueueFree();
        }

        EmitSignal("AbilityChanged");
    }


    public void OnHealthDeath()
    {
        EmitSignal("GameOver");
        base.OnHealthDeath();
    }
}

