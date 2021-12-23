package;

class PacketTool
{
	// Packet format : FromClient:1 | SenderID:";" | EventID:";" | Arguments:":"
	//
	// Events are stored in 2 differents arrays : the 1st for the names, the 2nd for the functions
	// In packets, ID are sent. They are the index of the events/events names in the arrays.
	public var eventsNames = new Array<String>();
	public var events = new Array<Array<String>->Void>();

	public var localID = -1;

	public static function createPacket(fromClient:Bool = true, id:String, event:String, arguments:Array<Any>):String
	{
		var packet = (if (fromClient) "1" else "0") + id + ";" + event + ";" + (for (arg in arguments)
			Std.string(arg) + ":");

		packet = packet.substring(0, packet.length - 1);

		return packet;
	}

	public static function registerEvent(name:String, onEvent:Array<String>->Void)
	{
		eventsNames.push(name);
		events.push(onEvent);
	}

	public static function parsePacket(packet:String):Void
	{
		var substrings = packet.split(";");

		var fromClient = Std.parseInt(substrings[0].substr(0, 1));
		var id = Std.parseInt(substrings[0].substr(1));
		var eventID = Std.parseInt(substrings[1]);
		var arguments = substrings[2].split(":");

		if (id != localID)
		{
			events[eventID](arguments);
		}
	}
}
