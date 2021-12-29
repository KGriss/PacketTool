package;

class PacketTool
{
	// Old packet format : FromClient:1 | SenderID:";" | EventID:";" | Arguments:":"
	// Packet format : SenderID:";" | EventID:";" | Arguments:":"
	//
	// Events are stored in 2 differents arrays : the 1st for the names, the 2nd for the functions
	// In packets, ID are sent. They are the index of the events/events names in the arrays.
	public static var eventsNames = new Array<String>();
	public static var events = new Array<(data:Array<String>, senderID:String, packet:String) -> Void>();

	public static var localID:String;
	public static var isClient:Bool;

	private static var _argumentsForPacket:String;
	private static var _packet:String;

	private static var _substrings:Array<String>;
	private static var _id:String;
	private static var _eventID:Int;
	private static var _arguments:Array<String>;

	private static inline final _CHARS_LIST:String = "1234567890AZERTYUIOPQSDFGHJKLMWXCVBNazertyuiopqsdfghjklmwxcvbn";
	private static var _tempID:String;

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

		PacketTool.isClient = isClient;
	}

	/*public static function authentificationPacket(packet:String):String
		{
			return createPacket("Authentification", []);
	}*/
	public static function createPacket(eventName:String, arguments:Array<Any>):String
	{
		_argumentsForPacket = "";
		for (arg in arguments)
		{
			_argumentsForPacket += Std.string(arg) + ":";
		}
		_argumentsForPacket = _argumentsForPacket.substr(0, _argumentsForPacket.length - 1);

		_packet = // (if (isClient) "1" else "0") +
			localID + ";" + Std.string(eventsNames.indexOf(eventName)) + ";" + _argumentsForPacket;

		return _packet;
	}

	public static function registerEvent(name:String, ?onEvent:(data:Array<String>, senderID:String, packet:String) -> Void)
	{
		eventsNames.push(name);
		if (onEvent != null)
		{
			events.push(onEvent);
		}
	}

	public static function parsePacket(packet:String):String
	{
		_substrings = packet.split(";");

		// var fromClient = Std.parseInt(substrings[0].substr(0, 1));
		_id = if (_substrings[0] != null) _substrings[0] else ""; // .substr(1);
		_eventID = if (_substrings[1] != null) Std.parseInt(_substrings[1]) else 0;
		_arguments = if (_substrings[2] != null) _substrings[2].split(":") else [];

		if (events[_eventID] != null)
		{
			events[_eventID](_arguments, _id, packet);
			return eventsNames[_eventID];
		}
		else
		{
			return null;
		}

		/*if (id != localID)
			{
				events[eventID](arguments, id);
		}*/
	}

	public static inline function generateID(length:Int = 4):String
	{
		_tempID = "";

		for (i in 0...length)
		{
			_tempID += _CHARS_LIST.charAt(Std.random(_CHARS_LIST.length));
		}

		return _tempID;
	}
}
