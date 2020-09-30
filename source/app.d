import std.stdio;
import tristanable.manager;
import std.socket;
import libdnet.dclient : DClient;
import std.string : cmp, split, strip;
import std.conv : to;
import notifications;
import std.file;
import std.json;

JSONValue config;

/* Current conneciton */
DClient dclient;

NotificationWatcher dnotifications;

Mode currentMode;

void main()
{
	/* If the configuration file exists */
	if(exists("config.example")) /* TODO: Change */
	{
		/* Load the config */
		loadConfig("config.example");
	}
	/* If the configuration file doesn't exist */
	else
	{
		/* Set default config */
		defaultConfig();
	}

	/* Start the REPL */
	commandLine();
}

void clientAuth(string username, string password)
{
	if(dclient.auth(username, password))
	{
		writeln("Auth good");
	}
	else
	{
		writeln("Auth bad");
	}
}

public enum Mode
{
	CHANNEL,
	USER,
	SERVER
}

void commandLine()
{
	

	/* The current command */
	string commandLine;

	string currentChannel;
	
	while(true)
	{
		/* Read in a command line */
		write(currentChannel~"~> ");
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
			bool isConfigConnect;
		
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

					isConfigConnect = true;
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

			/* TODO: How many are rtuend and which to use ? */
			addr = getAddress(address, to!(ushort)(port))[0];
			writeln("Connecting to "~to!(string)(addr)~"...");
			dclient = new DClient(addr);
			dnotifications= new NotificationWatcher(dclient.getManager());
			writeln("Connected!");

			if(isConfigConnect)
			{
				string server = elements[1];

				string username = config["servers"][server]["auth"]["username"].str();
				string password = config["servers"][server]["auth"]["password"].str();

				/* Authenticate the user */
				clientAuth(username, password);
				
				/* Auto join config */
				configAutoJoin(server);
			}
		}
		/* If the command is `auth` */
		else if(cmp(command, "auth") == 0)
		{
			string username = elements[1];
			string password = elements[2];

			/* Authenticate the user */
			clientAuth(username, password);
		}
		/* If the command is `list` */
		else if(cmp(command, "list") == 0 || cmp(command, "l") == 0)
		{
			string[] channels = dclient.list();
			writeln("Channels ("~to!(string)(channels.length)~" total)\n");
			foreach(string channel; channels)
			{
				write("\t"~channel~" (");
				ulong memberCount = dclient.getMemberCount(channel);
				writeln(to!(string)(memberCount)~")");
			}
		}
		/* If the command is `names` */
		else if(cmp(command, "names") == 0)
		{
			string[] members = dclient.getMembers(currentChannel);
			writeln(members);
		}
		/* If the command is `join` */
		else if(cmp(command, "join") == 0)
		{
			string[] channels = elements[1..elements.length];

			foreach(string channel; channels)
			{
				if(dclient.join(channel))
				{
					writeln("Already present in channel "~channel);
				}
			}

			currentChannel = elements[elements.length-1];
		}
		/* If the command is `query` */
		else if(cmp(command, "query") == 0)
		{
			/* Get the username to query */
			string user = elements[1];

			/* Set current "channel" to username */
			currentChannel = user;

			/* Set mode to USER */
			currentMode = Mode.USER;
		}
		else
		{
			/* If the current mode is `channel` then send to channel */
			if(currentMode == Mode.CHANNEL)
			{
				/* Send the current commandLine to the channel */
				dclient.sendMessage(false, currentChannel, strip(commandLine));
			}
			/* If the current mode is `user` then send to the user */
			else if(currentMode == Mode.USER)
			{
				dclient.sendMessage(true, currentChannel, strip(commandLine));
			}
			
		}
	}

	if(dclient)
	{
		/* TODO: Fix in tristanable */
		dclient.close();
	}
	
}

void configAutoJoin(string server)
{
	foreach(JSONValue value; config["servers"][server]["channels"].array())
	{
		string channel = value.str();
		//import core.thread;
		//Thread.getThis().sleep(dur!("seconds")(1));
		if(dclient.join(channel))
		{
			writeln("Already present in channel "~channel);
		}
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
	/* Open the provided configuration file */
	File file;
	file.open(configPath);

	/* Read the configuration file */
	byte[] buffer;
	buffer.length = file.size();
	buffer = file.rawRead(buffer);

	/* Close the file */
	file.close();

	/* Parse the JSON of the configuration file */
	config = parseJSON(cast(string)buffer);
}