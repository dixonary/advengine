package adventure;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import adventure.Object;
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

    // The text box which contains the name of objects
    var nameText:FlxText   = new FlxText();

    // Layers of the room
    var roomLayer:FlxGroup = new FlxGroup();
    var backLayer:FlxGroup = new FlxGroup();
    var charLayer:FlxGroup = new FlxGroup();
    var foreLayer:FlxGroup = new FlxGroup();
    public var speeches:FlxGroup = new FlxGroup();

    // Set of layers (can access publically)
    public var layers:Map<Layer, FlxGroup> = new Map();

    public static var menu:Menu;

    override public function create():Void {

        // Create and add layers
        add(roomLayer);
        add(backLayer);
        add(charLayer);
        add(foreLayer);
        add(speeches);
        layers.set(Layer.ROOM, roomLayer);
        layers.set(Layer.BACK, backLayer);
        layers.set(Layer.CHAR, charLayer);
        layers.set(Layer.FORE, foreLayer);

        // Create and add the object label
        nameText.setFormat("assets/fonts/pixelade.ttf");
        nameText.size = 40;
        add(nameText);

        Global.fader = new Fader();
        add(Global.fader);

        switchRoom(Global.startingRoom);

        // Create and add countdown timer (hidden and paused by default)
        Global.countdown = new Countdown();
        add(Global.countdown);

        // Add the inventory to the screen (empty by default)
        add(Global.inventory); // adds the inventory to the screen

        menu = new Menu();
        add(menu);

        super.create();
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

#if !html5
        if(FlxG.keys.justPressed.Q) Sys.exit(0);
#end
        if(FlxG.keys.justPressed.F) FlxG.fullscreen = !FlxG.fullscreen;

        if(FlxG.keys.justPressed.ESCAPE) menu.toggle();

        if(Global.speaking || Global.cutscene) {
            Global.canInteract = false;
        }
        else {
            Global.canInteract = true;
        }
        Global.speaking = false;

        if(Global.canInteract) {

            // Create a list of possible objects to interact with
            var os = [];//Global.currentRoom.objects.copy();
            os = os.concat(cast layers[Layer.FORE].members.copy().filter(function(s)return Std.is(s,Object)));
            os = os.concat(cast layers[Layer.CHAR].members.copy().filter(function(s)return Std.is(s,Object)));
            os = os.concat(cast layers[Layer.BACK].members.copy().filter(function(s)return Std.is(s,Object)));
            os = os.concat(cast layers[Layer.ROOM].members.copy().filter(function(s)return Std.is(s,Object)));

            for(o in Global.inventory.objects) if(o != Global.objUsing) os.push(o);
            var k = os.find(function(o) {
                return o.hidden == false
                    && Global.objUsing != o
                    && o.overlapsPoint(FlxG.mouse.getPosition())
                    && (!(o.pixelPerfect) || o.isCursorOverPixels());
            });

            if(k != null) {
                if(FlxG.keys.justPressed.F5)
                    trace(k.type.getClassName());

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
                if(FlxG.mouse.justPressed) {
                    if(k != null) {
                        if(k.inInventory) {
                            Global.objUsing = k;
                        }
                        else if(Tick.ticks.length == 0 && Tick.newAllowed) {
                            k.pop();
                        }
                    }
                }
            }

            // Left/right click with object in hand
            else {
                var p = FlxG.mouse.getPosition();
                Global.objUsing.x = p.x-Global.objUsing.width/2;
                Global.objUsing.y = p.y-Global.objUsing.height/2;
                //FlxG.mouse.visible = false;
                if(FlxG.mouse.justPressed){
                    if(k != null) {
                        Global.objUsing.useOn(k);
                        Global.objUsing = null;
                        //FlxG.mouse.visible = true;
                    }
                }
                if(FlxG.mouse.justPressedRight) {
                    Global.objUsing = null;
                    //FlxG.mouse.visible = true;
                }
            }
        }

        if(FlxG.mouse.justPressedRight) {
            Tick.clear();
        }

        if(Tick.ticks.length == 0) {
            Tick.newAllowed = true;
        }

        // Hide names of objects if you can't interact
        nameText.visible = Global.canInteract;

        FlxG.mouse.visible = true;

        Event.update(elapsed);

    }

    public function switchRoom(R:Class<Room>, ?pX:Int, ?pY:Int) {

        Tick.clear();

        if(Global.currentRoom != null) {
            Global.currentRoom.v_leave();
            roomLayer.clear();
        }

        var rname = R.getClassName();

        if(Global.rooms.get(rname) == null) {
            Global.rooms.set(rname, R.createInstance([]));
            Global.currentRoom = Global.rooms.get(rname);
            Global.currentRoom.create();
        }

        var room = Global.rooms.get(rname);
        Global.currentRoom = room;
        roomLayer.add(room);

        var p = room.get(Player);
        if(p != null) {
            if(pX!=null&&pY!=null) {
                var pos = p.roomPos(pX,pY);
                p.x = pos.x; p.y=pos.y;
            }
        }

        room.v_enter();

    }
}
