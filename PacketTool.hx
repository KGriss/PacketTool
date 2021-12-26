package;

class PacketTool
{
	// Old packet format : FromClient:1 | SenderID:";" | EventID:";" | Arguments:":"
	// Packet format : SenderID:";" | EventID:";" | Arguments:":"
	//
	// Events are stored in 2 differents arrays : the 1st for the names, the 2nd for the functions
	// In packets, ID are sent. They are the index of the events/events names in the arrays.
	public static var eventsNames = new Array<String>();
	public static var events = new Array<(Array<String>, senderID:String) -> Void>();

	public static var localID:String;
	public static var isClient:Bool;

	public static function init(?localID:String, ?isClient:Bool = true)
	{
		if (localID == null)
		{
			PacketTool.localID = generateID();
		}
		else
		{
			PacketTool.localID = localID;
		}
		trace("LocalID", PacketTool.localID);

		PacketTool.isClient = isClient;
	}

	public static function createPacket(eventName:String, arguments:Array<Any>):String
	{
		var argumentsForPacket = "";
		for (arg in arguments)
		{
			argumentsForPacket += Std.string(arg) + ":";
		}
		trace("argumentsForPacket", argumentsForPacket);
		argumentsForPacket = argumentsForPacket.substring(0, argumentsForPacket.length - 1);
		trace("argumentsForPacket", argumentsForPacket);

		var packet = /* (if (isClient) "1" else "0") + */ localID
			+ ";"
			+ Std.string(eventsNames.indexOf(eventName))
			+ ";"
			+ argumentsForPacket;

		// packet = packet.substring(0, packet.length - 1);
		trace("Packet to send", packet);

		return packet;
	}

	public static function registerEvent(name:String, onEvent:(data:Array<String>, senderID:String) -> Void)
	{
		eventsNames.push(name);
		events.push(onEvent);
	}

	public static function parsePacket(packet:String):Void
	{
		trace(packet);
		var substrings:Array<String> = packet.split(";");

		// var fromClient = Std.parseInt(substrings[0].substr(0, 1));
		var id:String = substrings[0]; // .substr(1);
		var eventID:Int = Std.parseInt(substrings[1]);
		var arguments:Array<String> = substrings[2].split(":");

		// events[eventID](arguments);

		trace(id, localID);
		if (id != localID)
		{
			trace("id != localID : true");
			events[eventID](arguments, id);
		}
	}

	public static inline function generateID(length:Int = 4):String
	{
		var charList = "1234567890AZERTYUIOPQSDFGHJKLMWXCVBNazertyuiopqsdfghjklmwxcvbn";
		var tempID = "";

		for (i in 0...length)
		{
			tempID += charList.charAt(Std.random(charList.length));
		}

		return tempID;
	}
}
