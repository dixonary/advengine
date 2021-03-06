package adventure;

class Global {

    // If false, no objects can be used
    public static var canInteract:Bool          = true;
    public static var speaking:Bool             = false;
    public static var cutscene:Bool             = false;

    // The current object being used
    public static var objUsing:Object           = null;

    // Countdown timer
    public static var countdown:Countdown       = null;

    // List of all rooms
    public static var rooms:Map<String,Room>    = new Map();

    // Inventory
    public static var inventory:Inventory       = new Inventory();

    // The current room
    public static var currentRoom:Room          = null;

    public static var startingRoom:Class<Room>  = null;
    public static var defaultScaleFactor:Int    = 8;

    public static var fader:Fader               = null;

}
