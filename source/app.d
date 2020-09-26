import std.stdio;

import tristanable.manager;
import std.socket;
import client;
import std.string : cmp, split, strip;
import std.conv : to;
import notifications;
import std.file;
import std.json;

JSONValue config;


void main()
{
	/* Check if the default config exists */
	if(exists("/home/deavmi/.config/skippy/config")) /* TODO: Change */
	{
		/* Load the config */
		loadConfig("/home/deavmi/.config/skippy/config");
	}
	else
	{
		/* Set default config */
		defaultConfig();
	}

	/* Start the REPL */
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
			string address;
			string port;
			Address addr;
		
			/* If there is only one argument then it is a server name */
			if(elements.length == 2)
			{
				string serverName = elements[1];
				
				try
				{
					/* Get the address and port */
					JSONValue serverInfo = config["servers"][serverName];
					address = serverInfo["address"].str();
					port = serverInfo["port"].str();
				}
				catch(JSONException e)
				{
					writeln("Could not find server: "~to!(string)(e));
					continue;
				}
			}
			/* Then it must be `<address> <port>` */
			else if(elements.length == 3)
			{
				address = elements[1];
				port = elements[2];
			}
			/* Syntax error */
			else
			{
				writeln("Syntax error");
				continue;
			}

			addr = parseAddress(address, to!(ushort)(port));
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
			writeln("Channels ("~to!(string)(channels.length)~" total)\n");
			foreach(string channel; channels)
			{
				writeln("\t"~channel);
			}
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

void defaultConfig()
{
	/* Server block */
	JSONValue serverBlock;

	/* TODO: Remove test servers? */
	JSONValue dserv;
	dserv["address"] = "127.0.0.1";
	dserv["port"] = "7777";
	// JSONValue[] joins = []
	// dserv["joins"] =
	serverBlock["dserv"] = dserv;

	config["servers"] = serverBlock;
}

void loadConfig(string configPath)
{
	/* TODO: Implement me */
	File file;
	file.open(configPath);

	byte[] buffer;
	buffer.length = file.size();
	buffer = file.rawRead(buffer);
}