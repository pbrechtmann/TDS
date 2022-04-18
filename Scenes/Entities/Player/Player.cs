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

            dropSpawner.SpawnItemDrop(packed, );

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

unc pickup_weapon(weapon_scene : PackedScene) -> void:
	var new_weapon = weapon_scene.instance()
	if new_weapon is WeaponMelee:
		var packed : PackedScene = PackedScene.new()

        if packed.pack(weapon_melee) != OK:
			printerr("Packing weapon failed")

        drop_spawner.spawn_item_drop(packed, ItemDrop.ITEM_TYPE.WEAPON, weapon_melee.drop_icon, melee_container.global_position)


        var old_weapon : WeaponMelee = weapon_melee

        weapon_melee = new_weapon

        melee_container.add_child(weapon_melee)

        weapon_melee.init(self, max(old_weapon.get_dps(), weapon_ranged.get_dps()), new_weapon.new_weapon)


        old_weapon.queue_free()


        switch_to_melee()


    elif new_weapon is WeaponRanged:
		var packed : PackedScene = PackedScene.new()

        if packed.pack(weapon_ranged) != OK:
			printerr("Packing weapon failed")

        drop_spawner.spawn_item_drop(packed, ItemDrop.ITEM_TYPE.WEAPON, weapon_ranged.drop_icon, ranged_container.global_position)


        var old_weapon : WeaponRanged = weapon_ranged

        weapon_ranged = new_weapon

        ranged_container.add_child(weapon_ranged)

        weapon_ranged.init(self, max(old_weapon.get_dps(), weapon_melee.get_dps()), new_weapon.new_weapon)


        old_weapon.queue_free()


        switch_to_ranged()


    emit_signal("weapon_changed")


func pickup_ability(ability_scene : PackedScene) -> void:
	var new_ability = ability_scene.instance()
	var old_ability : Ability

    if ability:
		var packed : PackedScene = PackedScene.new()

        if packed.pack(ability) != OK:
			printerr("Packing ability failed")

        drop_spawner.spawn_item_drop(packed, ItemDrop.ITEM_TYPE.ABILITY, ability.drop_icon, global_position)

        old_ability = ability


    ability_container.add_child(new_ability)

    ability = new_ability


    if old_ability:
		old_ability.queue_free()


    emit_signal("ability_changed")

