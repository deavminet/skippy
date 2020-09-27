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
		byte[] data = [0];
		data ~= cast(byte)username.length;
		data ~= username;
		data ~= password;

		manager.sendMessage(1, data);
		byte[] resp = manager.receiveMessage(1);

		return cast(bool)resp[0];
	}


	public bool join(string channel)
	{
		/* TODO: DO oneshot as protocol supports csv channels */
		byte[] data = [3];
		data ~= channel;

		manager.sendMessage(1, data);
		byte[] resp = manager.receiveMessage(1);

		return cast(bool)resp[0];
	}

	public string[] list()
	{
		string[] channels;

		byte[] data = [6];

		manager.sendMessage(1, data);
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

	public void sendMessage(string director, string message)
	{
		//
	}

	public void disconnect()
	{
		manager.stopManager();	
		writeln("manager stopped");
	}
}