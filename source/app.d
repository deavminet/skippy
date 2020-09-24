import std.stdio;

import tristanable.manager;
import std.socket;
import client;
import std.string : cmp, split, strip;
import std.conv : to;

void main()
{
	commandLine();
}

void commandLine()
{
	/* Current conneciton */
	DClient client;

	/* The current command */
	string commandLine;
	
	while(true)
	{
		/* Read in a command line */
		write("> ");
		commandLine = readln();

		if(cmp(strip(commandLine), "") == 0)
		{
			continue;
		}

		string[] elements = split(commandLine);
		string command = elements[0];
		
		/* If the command is `exit` */
		if(cmp(command, "exit") == 0)
		{
			break;
		}
		/* If the command is `connect` */
		else if(cmp(command, "connect") == 0)
		{
			string address = elements[1];
			string port = elements[2];
			Address addr = parseAddress(address, to!(ushort)(port));

			writeln("Connecting to "~to!(string)(addr)~"...");
			client = new DClient(addr);
			writeln("Connected!");
		}
		/* If the command is `auth` */
		else if(cmp(command, "auth") == 0)
		{
			string username = elements[1];
			string password = elements[2];

			client.auth(username, password);
		}
	}

	if(client)
	{
		
	}
	
}
