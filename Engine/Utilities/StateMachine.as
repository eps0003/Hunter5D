#include "Serializable.as"

shared class StateMachine : Serializable
{
	private dictionary states;
	private uint currentIdentifier = -1;

	void AddState(uint identifier, State@ state)
	{
		states.set("" + identifier, @state);
	}

	bool isState(uint identifier)
	{
		return identifier == currentIdentifier;
	}

	State@ getState(uint identifier)
	{
		State@ state;
		states.get("" + identifier, @state);
		return state;
	}

	State@ getCurrentState()
	{
		return getState(currentIdentifier);
	}

	void SetState(uint identifier)
	{
		State@ currentState = getCurrentState();
		State@ newState = getState(identifier);

		// Nonexistent state
		if (newState is null)
		{
			error("Attempted to set nonexistent state: " + identifier);
			printTrace();
			return;
		}

		// Cannot change to same state
		if (currentState is newState)
		{
			return;
		}

		if (currentState !is null)
		{
			currentState.Exit(this);
		}

		currentIdentifier = identifier;

		newState.Enter(this);
	}

	void Update()
	{
		State@ currentState = getCurrentState();
		if (currentState !is null)
		{
			currentState.Tick(this);
		}
	}

	void SerializeInit(CBitStream@ bs)
	{
		SerializeTick(bs);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		return deserializeTick(bs);
	}

	void SerializeTick(CBitStream@ bs)
	{
		bs.write_u32(currentIdentifier);
	}

	bool deserializeTick(CBitStream@ bs)
	{
		uint newCurrentIdentifier;
		if (!bs.saferead_u32(newCurrentIdentifier)) return false;

		SetState(newCurrentIdentifier);

		return true;
	}
}

shared class State
{
	void Enter(StateMachine@ states) {}
	void Tick(StateMachine@ states) {}
	void Exit(StateMachine@ states) {}
}
