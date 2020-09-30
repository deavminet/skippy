import core.thread : Thread;
import tristanable.manager;
import tristanable.notifications;
import std.stdio;
import core.time : dur;
import tristanable.encoding;

public class NotificationWatcher : Thread
{
	private Manager manager;

	this(Manager manager)
	{
		super(&worker);
	
		this.manager = manager;
		manager.reserveTag(0);

		start();
	}

	private void worker()
	{
		while(true)
		{
			/* Check for notifications every 2 seconds */
			NotificationReply[] notifications =manager.popNotifications();

			if(notifications.length)
			{
				//writeln(notifications);
				foreach(NotificationReply notificationReply; notifications)
				{
					//writeln(notificationReply.getData());
					string msg = cast(string)notificationReply.getData();
					//writeln("!> "~msg);
					process(notificationReply.getData());
				}
			}

			Thread.getThis().sleep(dur!("seconds")(2));
		}
	}

	/**
	* Processes an incoming notification
	* accordingly
	*/
	private void process(byte[] data)
	{
		/* TODO: Implement me */

		/* TODO: Check notification type */
		byte notificationType = data[0];

		/* For normal message (to channel or user) */
		if(notificationType == cast(byte)0)
		{
			/* TODO: Decode using tristanable */
			writeln("new message");
		}
		/* Channel notification (ntype=1) */
		else if(notificationType == cast(byte)1)
		{
			/* TODO: Decode using tristanable */
			/* TODO: Get the username of the user that left */
			//writeln("user left/join message");

			/* Get the sub-type */
			byte subType = data[1];

			/* If the notification was leave (stype=0) */
			if(subType == cast(byte)0)
			{
				string username = cast(string)data[2..data.length];
				writeln("<-- "~username~" left the channel");
			}
			/* If the notification was join (stype=1) */
			else if(subType == cast(byte)1)
			{
				string username = cast(string)data[2..data.length];
				writeln("--> "~username~" joined the channel");
			}
			/* TODO: Unknown */
			else
			{
				
			}
		}
	}
}