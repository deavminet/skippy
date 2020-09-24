import tristanable.manager : Manager;
import std.socket;
import std.stdio;
import std.conv : to;

public class DClient
{
	/**
	* tristanabale tag manager
	*/
	private Manager manager;

	this(Address address)
	{
		/* Initialize the socket */
		Socket socket = new Socket(AddressFamily.INET, SocketType.STREAM, ProtocolType.TCP);
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

	public void auth(string username, string password)
	{
		byte[] data = [0];
		data ~= cast(byte)username.length;
		data ~= username;
		data ~= password;
		writeln(data);
		manager.sendMessage(1, data);
		byte[] resp = manager.receiveMessage(1);
		writeln("auth resp: "~to!(string)(resp));
	}

	public void disconnect()
	{
		manager.stopManager();	
		writeln("manager stopped");
	}
}