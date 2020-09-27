import tristanable.manager : Manager;
import std.socket;
import std.stdio;
import std.conv : to;
import std.string : split;

public class DClient
{
	/**
	* tristanabale tag manager
	*/
	private Manager manager;

	this(Address address)
	{
		/* Initialize the socket */
		Socket socket = new Socket(address.addressFamily, SocketType.STREAM, ProtocolType.TCP);
		socket.connect(address);
		
		/* Initialize the manager */
		manager = new Manager(socket);

		//init();
	}

	public void init()
	{
		manager.sendMessage(1, [0,4,65,66,66,65,69,69]);
		writeln(manager.receiveMessage(1));
	}

	public bool auth(string username, string password)
	{
		/* The protocol data to send */
		byte[] data = [0];
		data ~= cast(byte)username.length;
		data ~= username;
		data ~= password;

		/* Send the protocol data */
		manager.sendMessage(1, data);

		/* Receive the server's response */
		byte[] resp = manager.receiveMessage(1);

		return cast(bool)resp[0];
	}


	public bool join(string channel)
	{
		/* TODO: DO oneshot as protocol supports csv channels */

		/* The protocol data to send */
		byte[] data = [3];
		data ~= channel;

		/* Send the protocol data */
		manager.sendMessage(1, data);

		/* Receive the server's response */
		byte[] resp = manager.receiveMessage(1);

		return cast(bool)resp[0];
	}

	public string[] list()
	{
		string[] channels;

		/* The protocol data to send */
		byte[] data = [6];

		/* Send the protocol data */
		manager.sendMessage(1, data);

		/* Receive the server's response */
		byte[] resp = manager.receiveMessage(1);

		string channelList = cast(string)resp[1..resp.length];
		channels = split(channelList, ",");

		/* TODO: Throw error on resp[0] zero */

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
		manager.sendMessage(1, protocolData);

		/* Receive the server's response */
		byte[] resp = manager.receiveMessage(1);

		return cast(bool)resp[0];
	}

	public void disconnect()
	{
		manager.stopManager();	
		writeln("manager stopped");
	}
}