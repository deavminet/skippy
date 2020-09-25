import std.stdio;

import tristanable.manager;
import std.socket;
import client;
import std.string : cmp, split, strip;
import std.conv : to;
import notifications;

void main()
{
	commandLine();
}

void commandLine()
{
	/* Current conneciton */
	DClient client;

	NotificationWatcher d;

	/* The current command */
	string commandLine;

	string currentChannel;
	
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
			d = new NotificationWatcher(client.getManager());
			writeln("Connected!");
		}
		/* If the command is `auth` */
		else if(cmp(command, "auth") == 0)
		{
			string username = elements[1];
			string password = elements[2];

			if(client.auth(username, password))
			{
				writeln("Auth good");
			}
			else
			{
				writeln("Auth bad");
			}
		}
		/* If the command is `list` */
		else if(cmp(command, "list") == 0)
		{
			string[] channels = client.list();
			writeln(channels);
		}
		/* If the command is `join` */
		else if(cmp(command, "join") == 0)
		{
			string[] channels = elements[1..elements.length];

			foreach(string channel; channels)
			{
				if(client.join(channel))
				{
					writeln("Already present in channel "~channel);
				}
			}

			currentChannel = elements[elements.length-1];
		}
		/* If the command is `msg` */
		else if(cmp(command, "open") == 0)
		{
			
		}
		else
		{
			//client.sendMessage()
		}
	}

	if(client)
	{
		client.disconnect();
	}
	
}
