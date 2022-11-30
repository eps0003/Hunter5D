namespace Command
{
	bool unwrap(CBitStream@ params, bool thisGameOnly = false)
	{
		u8 gameIndex;
		if (!params.saferead_u8(gameIndex)) return false;

		u8 currentGameIndex = getRules().get_u8("game index");
		if (thisGameOnly && gameIndex != currentGameIndex) return false;

		uint size;
		if (!params.saferead_u32(size)) return false;

		CBitStream bs;
		bs.writeBitStream(params, params.getBitIndex(), size);

		params = bs;
		params.ResetBitIndex();
		return true;
	}

	CBitStream wrap(CBitStream@ params)
	{
		CBitStream bs;
		bs.write_u8(getRules().get_u8("game index"));
		bs.write_u32(params.getBitsUsed());
		bs.writeBitStream(params);
		return bs;
	}

	bool equals(u8 cmd, string cmdName)
	{
		return cmd == getRules().getCommandID(cmdName);
	}

	void Add(string cmdName)
	{
		getRules().addCommandID(cmdName);
	}

	void Send(string cmdName, CBitStream &in params, bool sendToClients = true)
	{
		CRules@ rules = getRules();
		rules.SendCommand(rules.getCommandID(cmdName), params, sendToClients);
	}

	void Send(string cmdName, CBitStream &in params, CPlayer@ player)
	{
		CRules@ rules = getRules();
		rules.SendCommand(rules.getCommandID(cmdName), params, player);
	}
}
