package;

import haxe.Serializer;
import haxe.Unserializer;

// This version is untested and may be broken
// It's based on an old PacketTool version so I need to update it

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

		PacketTool.isClient = isClient;

		if (PacketTool.isClient)
		{
			registerEvent("Authentification", function(data:Array<String>, senderID:String) {});
		}
		else
		{
			registerEvent("Authentification", function(data:Array<String>, senderID:String) {});
		}
	}

	/*public static function authentificationPacket(packet:String):String
		{
			return createPacket("Authentification", []);
	}*/
	public static function createPacket(eventName:String, arguments:Array<Any>, argumentsData:Dynamic):String
	{
		var argumentsSerializer = new Serializer();
		argumentsSerializer.serialize(argumentsData);

		/*var unserializer = new Unserializer();
			for (arg in arguments)
			{
				argumentsForPacket += Std.string(arg) + ":";
			}
			argumentsForPacket = argumentsForPacket.substring(0, argumentsForPacket.length - 1); */
		/*var packet = // (if (isClient) "1" else "0") +
			localID + ";" + Std.string(eventsNames.indexOf(eventName)) + ";" + argumentsForPacket; */
		var packet = localID + ";" + Std.string(eventsNames.indexOf(eventName)) + ";" + argumentsSerializer.toString();

		return packet;
	}

	public static function registerEvent(name:String, onEvent:(data:Array<String>, senderID:String) -> Void)
	{
		eventsNames.push(name);
		events.push(onEvent);
	}

	public static function parsePacket(packet:String):Void
	{
		var substrings:Array<String> = packet.split(";");

		// var fromClient = Std.parseInt(substrings[0].substr(0, 1));
		var id:String = if (substrings[0] != null) substrings[0] else ""; // .substr(1);
		var eventID:Int = if (substrings[1] != null) Std.parseInt(substrings[1]) else 0;
		// var arguments:Array<String> = if (substrings[2] != null) substrings[2].split(":") else [];
		var argumentsData:Dynamic = if (substrings[2] != null) new Unserializer(substrings[2]).unserialize() else [];

		events[eventID](argumentsData, id);

		/*if (id != localID)
			{
				events[eventID](arguments, id);
		}*/
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
