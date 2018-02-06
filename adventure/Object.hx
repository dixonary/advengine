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
    public var type(get,never):Class<Object>;

    public var moveSpeed    :Float  = 5;        // How fast the object moves when walking
    public var customName   :String ="";        // Something different to show up
    public var hideName     :Bool   = false;    // Whether to hide the name on hover
    public var hidden       :Bool   = false;    // Whether to allow the object to be clicked / hovered
    public var pixelPerfect :Bool   = true;     // Whether to use pixel perfect hovering
    public var speechColor  :Int    = 0xff000000;



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

        changeScale();
        var pos = roomPos(X,Y);
        x = pos.x;
        y = pos.y;
        layer = BACK;

    }
    public function changeScale(S:Float=-1) {
        offset.set(width/2,height/2);
        if(room == null) return;
        var s = S==-1?room.scaleFactor:S;
        scale.set(s, s);
        updateHitbox();
        width = frameWidth * s;
        height = frameHeight * s;
        offset.set(0,0);
        origin.set(0,0);
    }

    override public function toString(){
        return name;
    }


    override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):FlxSprite {
        var x = super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
        changeScale();
        return x;
    }


    override public function update(d) {

        if(inInventory)
            room = Global.currentRoom;


        if(move != null) {
           // trace(move);
            if(Math.abs(move.x-x) < moveSpeed) x = move.x;
            if(Math.abs(move.y-y) < moveSpeed) y = move.y;

            if(Math.abs(move.x-x) < moveSpeed && Math.abs(move.y-y) < moveSpeed) {
                var pmove = move;
                move = null;
                if(pmove.then != null) pmove.then();
            }
            else {
                if(Math.abs(move.x-x) >= moveSpeed)
                    x += moveSpeed * (move.x-x>0?1:-1);
                if(Math.abs(move.y-y) >= moveSpeed)
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
    public function use() {
        if(inInventory) {
            Global.objUsing = this;
        }
    }
    public function useOn(other:Object) {}

    /* Helper Functions */

    // Shorthand for name of object.
    public function get_name() {
        if(customName != "") return customName;
        var str = getClass().getClassName();
        var lastDot = str.lastIndexOf(".");
        if(lastDot != -1) {
            str = str.substr(lastDot+1);
        }
        return str.toLowerCase();
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
            var adjustedx = this.x +
                (FlxG.mouse.x - this.x) / this.scale.x;
            var adjustedy = this.y +
                (FlxG.mouse.y - this.y) / this.scale.y;
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

    public function walkToObject(other:Class<Object>, direction:Direction, approach:Approach, ?then:Null<Void->Void>) {

        var ob = room.get(other);

        var nx = 0.0;
        if(approach == LEFT) {
            nx = ob.x  - width;
        }
        else if(approach == RIGHT) {
            nx = ob.x + ob.width ;
        }
        else if(x < ob.x  - width)
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
                walkTo(nx, y,then);
            case Y:
                walkTo(x,ny,then);
            case BOTH:
                walkTo(nx,ny,then);
        }
    }

    public function walkTo(rawX, rawY, ?then:Null<Void->Void>) {
        move = {x:rawX, y:rawY, then:then};
    }

    public function say(s:String, ?col:Null<Int>, ?maxAge:Float = 3) {
        if(col == null) col = speechColor;
        speeches.push(cast cast(FlxG.state,Game).speeches.add(new Speech(s, this, col, maxAge)));
    }

    public function option(s:String, ?col:Null<Int>, ?then:Void->Void):Void {
        if(col == null) col = speechColor;
        if(dialogs == 0) clearSpeeches();
        dialogs++;
        speeches.push(cast cast(FlxG.state,Game).speeches.add(new Speech.DialogOption(
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

    public function afterAnimation(callback:Void->Void) {
        animation.finishCallback = function(s) {
            animation.finishCallback = null;
            callback();
        }
    }

    public function get_type() {
        return Type.getClass(this);
    }

}

enum Direction {
    X;
    Y;
    BOTH;
}

enum Approach {
    LEFT;
    RIGHT;
    ANY;
}
