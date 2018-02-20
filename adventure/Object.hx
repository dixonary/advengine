package adventure;
using Reflect;
using Lambda;
using Type;
using Std;
import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
using StringTools;

class Object extends FlxSprite {

    // Useful variables
    public var name(get,never)       :String;
    public var layer(default,set)    :Layer;
    public var game(get,never)       :Game;
    public var type(get,never):Class<Object>;

    public var moveSpeed    :Float  = 300;      // How fast the object moves when walking
    public var customName   :String ="";        // Something different to show up
    public var hideName     :Bool   = false;    // Whether to hide the name on hover
    public var hidden       :Bool   = false;    // Whether to allow the object to be clicked / hovered
    public var pixelPerfect :Bool   = true;     // Whether to use pixel perfect hovering
    public var speechColor  :Int    = 0xffffffff;

    var ticks:Array<{word:String,callback:Void->Void}> = [];

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

        ticks = [
            {word: "LOOK", callback: look},
            {word: "USE" , callback: use }
        ];

        pixelPerfectRender = false;

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


    override public function update(d:Float) {

        if(inInventory)
            room = Global.currentRoom;

        if(speeches.length > 0) {
            Global.speaking = true;
        }

        if(move != null) {
           // trace(move);
            if(Math.abs(move.x-x) < moveSpeed*d) x = move.x;
            if(Math.abs(move.y-y) < moveSpeed*d) y = move.y;

            if(Math.abs(move.x-x) < moveSpeed*d && Math.abs(move.y-y) <
                    moveSpeed*d) {
                var pmove = move;
                move = null;
                if(pmove.then != null) pmove.then();
            }
            else {
                if(Math.abs(move.x-x) >= moveSpeed*d)
                    x += moveSpeed *d* (move.x-x>0?1:-1);
                if(Math.abs(move.y-y) >= moveSpeed*d)
                    y += moveSpeed *d* (move.y-y>0?1:-1);
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


    public function pop() {

        Tick.clear();
        Global.cutscene = true;

        var minAngle = -45;
        var maxAngle = 45;
        var total = ticks.length-1;
        var count = 0;
        for(t in ticks) {
            if(total == 0) {
                FlxG.state.add(new Tick(
                    x+width/2, y, 0,t.word, t.callback));
                break;
            }

            FlxG.state.add(new Tick(
                x+width/2, y, (maxAngle-minAngle)*count/total + minAngle,
                t.word, t.callback));
            count++;
        }

        Tick.onClear(function() {
            Global.cutscene = false;
        });

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


    override public function pixelsOverlapPoint(point:FlxPoint, Mask:Int = 0xFF, ?Camera:FlxCamera):Bool
    {
        if (Camera == null)
            Camera = FlxG.camera;

        getScreenPosition(_point, Camera);
        _point.subtractPoint(new FlxPoint(offset.x/scale.x,offset.y/scale.y));
        _flashPoint.x = (point.x - Camera.scroll.x) - _point.x;
        _flashPoint.y = (point.y - Camera.scroll.y) - _point.y;

        point.putWeak();

        // 1. Check to see if the point is outside of framePixels rectangle
        if (_flashPoint.x < 0 || _flashPoint.x > frameWidth || _flashPoint.y < 0 || _flashPoint.y > frameHeight)
        {
            return false;
        }
        else // 2. Check pixel at (_flashPoint.x, _flashPoint.y)
        {
            var frameData:BitmapData = updateFramePixels();
            var pixelColor:FlxColor = frameData.getPixel32(Std.int(_flashPoint.x), Std.int(_flashPoint.y));
            return pixelColor.alpha * alpha >= Mask;
        }
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
