using Godot;
using System;

public class ActionLock : Node
{
    private int _moveLocks = 0;
    private int _actionLocks = 0;


    public void AddActionLock() {
        _actionLocks++;
    }


    public void RemoveActionLock() {
        _actionLocks--;
    }


    public bool IsActionLocked() {
        return _actionLocks != 0;
    }


    public void AddMoveLock() {
        _moveLocks++;
    }


    public void RemoveMoveLock() {
        _moveLocks--;
    }


    public bool IsMoveLocked() {
        return _moveLocks != 0;
    }
}
