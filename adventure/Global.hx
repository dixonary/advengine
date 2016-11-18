package adventure;

class Global {

    // If false, no objects can be used
    public static var canInteract:Bool          = true;

    // The current object being used
    public static var objUsing:Object           = null;

    // Countdown timer
    public static var countdown:Countdown       = new Countdown();

    // List of all rooms
    public static var rooms:Map<Class<Room>,Room>= new Map();

    // Inventory
    public static var inventory:Inventory       = new Inventory();

    // The current room
    public static var currentRoom:Room          = null;

}
