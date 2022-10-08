#include "ChatCommand.as"

class HelpCommand : ChatCommand
{
	HelpCommand()
	{
		super("help", "List available commands");
		AddAlias("commands");
	}

	void Execute(string[] args, CPlayer@ player)
	{
		if (!isServer()) return;

		ChatCommandManager@ manager = ChatCommands::getManager();
		ChatCommand@[]@ commands = manager.getExecutableCommands(player);

		for (uint i = 0; i < commands.size(); i++)
		{
			ChatCommand@ command = commands[i];

			string[] names;
			for (uint i = 0; i < command.aliases.size(); i++)
			{
				string alias = command.aliases[i];
				string cmdName = "!" + alias;
				if (command.usage != "")
				{
					cmdName += " " + command.usage;
				}
				names.push_back(cmdName);
			}

			server_AddToChat(join(names, ", "), ConsoleColour::CRAZY, player);
			server_AddToChat("   ↳ " + getTranslatedString(command.description), ConsoleColour::INFO, player);
		}
	}
}
