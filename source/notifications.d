import core.thread : Thread;
import tristanable.manager;
import tristanable.notifications;
import std.stdio;
import core.time : dur;

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
				writeln(notifications);
				foreach(NotificationReply notificationReply; notifications)
				{
					writeln(notificationReply.getData());
					string msg = cast(string)notificationReply.getData();
					writeln("!> "~msg);
				}
			}

			Thread.getThis().sleep(dur!("seconds")(2));
		}
	}
}