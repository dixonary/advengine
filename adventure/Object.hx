package adventure;
using Reflect;
using Lambda;
using Type;
using Std;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.system.FlxAssets;
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
    public var move         :Null<{x:Float,y:Float, ?then:Void->Void}> = null;
    public var speeches     :Array<Speech> = [];
    public var dialogs      :Int = 0;
    public var room         :Room;
    public var inInventory  :Bool = false;

    public function new(X:Int, Y:Int,?asset:String) {
        super();
        if(asset == null) loadGraphic('assets/images/$name.png');
        else              loadGraphic('assets/images/$asset.png');

        room = Global.currentRoom;

        updateScale();
        var pos = roomPos(X,Y);
        x = pos.x;
        y = pos.y;
        layer = BACK;
        offset.set(0,0);
        origin.set(0,0);


    }
    public function updateScale() {
        scale.set(room.scaleFactor, room.scaleFactor);
        trace(room.scaleFactor);
        updateHitbox();
    }


    override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):FlxSprite {
        var x = super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
        updateScale();
        offset.set(0,0);
        origin.set(0,0);
        return x;
    }


    override public function update(d) {
        if(move != null) {
            if(Math.abs(move.x-x) < moveSpeed) x = move.x;
            if(Math.abs(move.y-y) < moveSpeed) y = move.y;

            if(Math.abs(move.x-x) < moveSpeed && Math.abs(move.y-y) < moveSpeed) {
                var pmove = move;
                move = null;
                if(pmove.then != null) pmove.then();
            }
            else {
                x += moveSpeed * (move.x-x>0?1:-1);
                y += moveSpeed * (move.y-y>0?1:-1);
            }
        }

        //updateHitbox();
        //offset.x +=((x-currentRoom.x) % Game.SCALE_FACTOR);

        for(i in 0...speeches.length) {
            var s = speeches[i];
            s.text.visible = true;
            s.x = x+width/2-s.width/2;
            s.y = y-(0.3+speeches.length-i)*Speech.SIZE;
        }

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
        return Math.floor((x - room.x)/room.scaleFactor);
    }

    public function die() {
        killEvents();
    }

    public function killEvents() {
    }

    public function walkToObject(other:Class<Object>, direction:Direction) {

        var ob = room.get(other);

        var nx = 0.0;
        if(x < ob.x  - width)
            nx = ob.x  - width;
        else if(x > ob.x + ob.width )
            nx = ob.x + ob.width ;
        else
            nx = x;

        var ny = 0.0;
        if(y < ob.y  - height)
            ny = ob.y  - height;
        else if(y > ob.y + ob.height )
            ny = ob.y + ob.height ;
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
        speeches.push(cast FlxG.state.add(new Speech.DialogOption(
            s,this,speeches.length+1,then)));
    }
    public function endOptions() {
        dialogs = 0;
    }

    public function clearSpeeches() {
            for(s in speeches)
                s.kill();
            speeches = [];
            move = null;
    }


}

enum Direction {
    X;
    Y;
    BOTH;
}
