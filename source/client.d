import tristanable.manager : Manager;
import std.socket;
import std.stdio;
import std.conv : to;
import std.string : split;

public final class DClient
{
	/**
	* tristanabale tag manager
	*/
	private Manager manager;


	/* TODO: Tristsnable doesn't, unlike my java version, let youn really reuse tags */
	/* TODO: Reason is after use they do not get deleted, only later by garbage collector */
	/* TODO: To prevent weird stuff from possibly going down, we use unique ones each time */
	private long i = 20;

	/**
	* Constructs a new DClient and connects
	* it to the given endpoint Address
	*
	* @param address the endpoint (server) to
	* connect to
	*/
	this(Address address)
	{
		/* Initialize the socket */
		Socket socket = new Socket(address.addressFamily, SocketType.STREAM, ProtocolType.TCP);
		socket.connect(address);
		
		/* Initialize the manager */
		manager = new Manager(socket);
	}

	public bool auth(string username, string password)
	{
		/* The protocol data to send */
		byte[] data = [0];
		data ~= cast(byte)username.length;
		data ~= username;
		data ~= password;

		/* Send the protocol data */
		manager.sendMessage(i, data);

		/* Receive the server's response */
		byte[] resp = manager.receiveMessage(i);
		i++;

		return cast(bool)resp[0];
	}


	/**
	* Joins the given channel
	*
	* @param channel the channel to join
	* @returns bool true if the join was
	* successful, false otherwise
	*/
	public bool join(string channel)
	{
		/* TODO: DO oneshot as protocol supports csv channels */

		/* The protocol data to send */
		byte[] data = [3];
		data ~= channel;

		/* Send the protocol data */
		manager.sendMessage(i, data);

		/* Receive the server's response */
		byte[] resp = manager.receiveMessage(i);
		i++;

		return cast(bool)resp[0];
	}

	/**
	* Lists all the channels on the server
	*
	* @returns string[] the list of channels
	*/

	public string[] list()
	{
		/* List of channels */
		string[] channels;

		/* The protocol data to send */
		byte[] data = [6];

		/* Send the protocol data */
		manager.sendMessage(i, data);

		/* Receive the server's response */
		byte[] resp = manager.receiveMessage(i);

		/* Only generate a list if command was successful */
		if(resp[0])
		{
			/* Generate the channel list */
			string channelList = cast(string)resp[1..resp.length];
			channels = split(channelList, ",");
		}

		i++;

		return channels;
	}

	public Manager getManager()
	{
		return manager;
	}

	/**
	* Sends a message to either a channel of user
	*
	* @param isUser whether or not we are sending to
	* a user, true if user, false if channel
	* @param location the username/channel to send to
	* @param message the message to send
	* @returns bool whether the send worked or not
	*/
	public bool sendMessage(bool isUser, string location, string message)
	{
		/* The protocol data to send */
		byte[] protocolData = [5];

		/**
		* If we are sending to a user then the
		* type field is 0, however if to a channel
		* then it is one
		*
		* Here we encode that
		*/
		protocolData ~= [!isUser];

		/* Encode the length of `location` */
		protocolData ~= [cast(byte)location.length];

		/* Encode the user/channel name */
		protocolData ~= cast(byte[])location;

		/* Encode the message */
		protocolData ~= cast(byte[])message;

		/* Send the protocol data */
		manager.sendMessage(i, protocolData);

		/* Receive the server's response */
		byte[] resp = manager.receiveMessage(i);
		i++;
		return cast(bool)resp[0];
	}

	public void disconnect()
	{
		manager.stopManager();	
		writeln("manager stopped");
	}
}