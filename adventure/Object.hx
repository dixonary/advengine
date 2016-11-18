package adventure;
using Reflect;
using Lambda;
using Type;
using Std;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
using StringTools;

class Object extends FlxSprite {

    // Useful variables
    public var name(get,never)       :String;
    public var layer(default,set)    :Layer;
    public var game(get,never)       :Game;

    public var moveSpeed    :Float  = 5;        // How fast the object moves when walking
    public var customName   :String ="";        // Something different to show up
    public var hideName     :Bool   = false;    // Whether to hide the name on hover
    public var hidden       :Bool   = false;    // Whether to allow the object to be clicked / hovered
    public var pixelPerfect :Bool   = true;     // Whether to use pixel perfect hovering

    // Internal system stuff
    public var move         :Null<{pos:Float, then:Void->Void}> = null;
    public var speeches     :Array<Speech> = [];
    public var dialogs      :Int = 0;
    public var room         :Room;

    public function new(X:Int, Y:Int,?asset:String) {
        super();
        if(asset == null) loadGraphic('assets/images/$name.png');
        else              loadGraphic('assets/images/$asset.png');

        scale.set(room.scaleFactor, room.scaleFactor);
        updateHitbox();

        var pos = roomPos(X,Y);
        x = pos.x;
        y = pos.y;
        layer = BACK;

        room = Global.currentRoom;

    }

    override public function update(d) {
        super.update(d);
    }

    public function look() {}
    public function use() {}
    public function useOn(other:Object) {}

    /* Helper Functions */

    // Shorthand for name of object.
    public function get_name() {
        if(customName != "") return customName;
        return getClass().getClassName().toLowerCase();
    }

    public function get_game() {
        return cast(FlxG.state,Game);
    }

    public function v_useOn(o:Object) {
        if(field("useOn")!= null) {
            callMethod(field("useOn"), [o]);
        }
    }

    public function set_layer(L:Layer) {
            var g = cast(FlxG.state,Game);
            for(l in g.layers.iterator()) l.remove(this);
            g.layers.get(L).add(this);

        return layer = L;
    }

    // Work out where this object should be placed.
    public function roomPos(X:Float,Y:Float) {
        return {x:room.x + X*room.scaleFactor,
                y:room.y + Y*room.scaleFactor};
    }

    // Is the mouse hovering over this?
    public function isCursorOverPixels():Bool {
        if(pixelPerfect) {
            var adjustedx = this.getMidpoint().x +
                (FlxG.mouse.x - this.getMidpoint().x) / this.scale.x;
            var adjustedy = this.getMidpoint().y +
                (FlxG.mouse.y - this.getMidpoint().y) / this.scale.y;
            var adjustedCursorPos = new FlxPoint(adjustedx, adjustedy);
            return pixelsOverlapPoint(adjustedCursorPos);
        }
        else {
            return overlapsPoint(FlxG.mouse.getPosition());
        }
    }

    // How far apart are these two things in scaled pixels?
    public function pixelDistance(Other:Object):Int {
        if(x+width>Other.x && Other.x+Other.width > x) return 0;
        else if(x+width<=Other.x) return cast (Other.x-x-width)/room.scaleFactor;
        else                      return cast (x-Other.x-Other.width)/room.scaleFactor;
    }

    public function tileX(){
        return Math.floor((x - room.x)/room.SCALE_FACTOR);
    }

    public function die() {
        killEvents();
    }

    public function killEvents() {
    }

    public function walkToObject(other:Class<Object>, direction:Direction) {

        var ob = room.get(other);

        var nx = 0.0;
        if(x < ob.x - dist - width)
            nx = ob.x - dist - width;
        else if(x > ob.x + ob.width + dist)
            nx = ob.x + ob.width + dist;
        else
            nx = x;

        var ny = 0.0;
        if(y < ob.y - dist - height)
            ny = ob.y - dist - height;
        else if(y > ob.y + ob.height + dist)
            ny = ob.y + ob.height + dist;
        else
            ny = y;

        switch(direction) {
            case X:
                walkTo(nx, y);
            case Y:
                walkTo(x,ny);
            case BOTH:
                walkTo(nx,ny);
        }
    }

    public function walkTo(rawX, rawY) {
        move = {x:rawX, y:rawY};
    }

    public function say(s:String, ?col:Int=0xffffffff, ?maxAge:Float = 3) {
        speeches.push(cast FlxG.state.add(new Speech(s, this, col, maxAge)));
    }

    public function option(s:String, ?col:Int = 0xffffffff, ?then:Void->Void):Void {
        if(dialogs == 0) clearSpeeches();
        dialogs++;
        speeches.push(cast FlxG.state.add(new DialogOption(
            s,this,speeches.length+1,then)));
    }
    public function endOptions() {
        dialogs = 0;
    }

    public function clearSpeeches() {
            for(s in speeches)
                s.kill();
            speeches = [];
    }


}

enum Direction {
    X;
    Y;
    BOTH;
}
