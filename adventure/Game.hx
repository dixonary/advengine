package adventure;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.FlxCamera;
using Type;
using Reflect;
using Lambda;


/* The Game class contains everything which is being drawn to the screen
 * and manages things like the game layers.
 */

class Game extends FlxState {

    //How tall the room is, in pixels, on the screen
    public static var ROOM_HEIGHT:Int = 800;
    // The offset of the room from the top of the screen (guaranteed black space)
    public static var ROOM_TOP   :Int = 50;

    // Used for anything which isn't in a room
    public static var SCALE_FACTOR:Int = 5;

    // The text box which contains the name of objects
    var nameText:FlxText   = new FlxText();

    // Layers of the room
    var roomLayer:FlxGroup = new FlxGroup();
    var backLayer:FlxGroup = new FlxGroup();
    var charLayer:FlxGroup = new FlxGroup();
    var foreLayer:FlxGroup = new FlxGroup();

    var startingScreen:Class<Room>;

    // Set of layers (can access publically)
    public var layers:Map<Layer, FlxGroup> = new Map();

    public function new(screen:Class<Room>) {
       startingScreen = screen;
       super();
    }

    override public function create():Void {

        // Create and add layers
        add(roomLayer);
        add(backLayer);
        add(charLayer);
        add(foreLayer);
        layers.set(Layer.ROOM, roomLayer);
        layers.set(Layer.BACK, backLayer);
        layers.set(Layer.CHAR, charLayer);
        layers.set(Layer.FORE, foreLayer);

        // Create and add the object label
        nameText.setFormat("assets/fonts/PIXELADE.TTF");
        nameText.size = 40;
        add(nameText);

        switchRoom(startingScreen);

        // Create and add countdown timer (hidden and paused by default)
        add(Global.countdown);

        // Add the inventory to the screen (empty by default)
        add(Global.inventory); // adds the inventory to the screen

        super.create();
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if(FlxG.keys.justPressed.Q) Sys.exit(0);

        if(Global.canInteract) {

            // Create a list of possible objects to interact with
            var os = Global.currentRoom.objects.copy();
            for(o in Global.inventory.objects) if(o != Global.objUsing) os.push(o);
            var k = os.find(function(o) {
                return o.name != "player"
                    && o.hidden == false
                    && o.overlapsPoint(FlxG.mouse.getPosition())
                    && o.isCursorOverPixels();
            });
            if(k != null) {
                if(k.name != nameText.text) {
                    nameText.text = (if (k.hideName) "" else k.name);
                    nameText.fieldWidth = 1000;
                    nameText.offset.x = 0;
                    nameText.setBorderStyle(OUTLINE,0xff000000,2);
                    nameText.fieldWidth = nameText.textField.textWidth + 10;
                }
                nameText.x = k.x+k.width/2-nameText.width/2;
                nameText.y = k.y - 48;

            }
            else
                nameText.text = "";

            // Left/right click with open hand
            if(Global.objUsing == null) {
                if(FlxG.mouse.justPressed)
                    if(k != null) k.use();
                if(FlxG.mouse.justPressedRight)
                    if(k != null) k.look();
            }

            // Left/right click with object in hand
            else {
                var p = FlxG.mouse.getPosition();
                Global.objUsing.x = p.x-Global.objUsing.width/2;
                Global.objUsing.y = p.y-Global.objUsing.width/2;
                FlxG.mouse.visible = false;
                if(FlxG.mouse.justPressed){
                    if(k != null) {
                        Global.objUsing.useOn(k);
                        Global.objUsing = null;
                        FlxG.mouse.visible = true;
                    }
                }
                if(FlxG.mouse.justPressedRight) {
                    Global.objUsing = null;
                    FlxG.mouse.visible = true;
                }
            }
        }
        // Hide names of objects if you can't interact
        nameText.visible = Global.canInteract;

    }

    public function switchRoom(R:String, ?pX:Int, ?pY:Int) {

        if(Global.currentRoom != null) {
            Global.currentRoom.v_leave();
            roomLayer.clear();
        }

        if(Global.rooms.get(R) == null) {
            Global.rooms.set(R, R.createInstance([]));
            Global.currentRoom = Global.rooms.get(R);
            Global.rooms.get(R).create();
        }

        var room = Global.rooms.get(R);
        Global.currentRoom = room;
        roomLayer.add(room);

        var p = room.get(Player);
        if(pX!=null&&pY!=null) {
            var pos = p.roomPos(pX,pY);
            p.x = pos.x; p.y=pos.y;
        }

        room.v_enter();

    }
}
