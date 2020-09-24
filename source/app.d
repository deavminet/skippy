import std.stdio;

import tristanable.manager;
import std.socket;

void main()
{
	writeln("Edit source/app.d to start your project.");

	/* COnnect to the server */
	Socket socket = new Socket(AddressFamily.INET, SocketType.STREAM, ProtocolType.TCP);

	socket.connect(parseAddress("0.0.0.0",7777));

	/* Create a new tristanable manager */
	Manager manager = new Manager(socket);

	manager.sendMessage(1, [0,4,65,66,66,65,69,69]);

	writeln(manager.receiveMessage(1));
}
