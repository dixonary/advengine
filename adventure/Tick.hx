package adventure;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;
using flixel.util.FlxSpriteUtil;

class Tick extends FlxSprite {

    var TICK_SIZE:Int = 64;
    var TICK_OFFSET:Int = 64;
    static var ticks:Array<Tick> = [];

    var callback:Void->Void;

    public function new(X:Float,Y:Float,Angle:Float,Callback:Void->Void) {
        super();
        
        antialiasing = false;

        makeGraphic(TICK_SIZE, TICK_SIZE, 0x00ffffff, true);

        drawCircle(TICK_SIZE/2,TICK_SIZE/2, TICK_SIZE/2-2, 0xffdddddd);

        drawPolygon([
                new FlxPoint(TICK_SIZE*0.5,TICK_SIZE-2),
                new FlxPoint(TICK_SIZE,TICK_SIZE),
                new FlxPoint(TICK_SIZE-2,TICK_SIZE*0.5),
                ], 0xffdddddd);

        angle += 45;


        x = X;
        y = Y;
        angle += Angle;

        x += Math.sin(Angle) * TICK_OFFSET - TICK_SIZE/2;
        y -= Math.cos(Angle) * TICK_OFFSET;

        callback = Callback;

        ticks.push(this);

    }

    public static function clear() {
        for(t in Tick.ticks) {
            t.kill();
            t.destroy();
        }

        Tick.ticks = [];
    }

    override public function update(d) {
        super.update(d);
        
        if(
            Math.pow(FlxG.mouse.x-x-width/2,2) +
            Math.pow(FlxG.mouse.y-y-height/2,2) < 
            TICK_SIZE/2*TICK_SIZE/2 ) {

            if(FlxG.mouse.justPressed) {
                hit();
            }
        }
    }

    function hit() {
        if(callback != null) {
            callback();
        }

        Tick.clear();

    }

}

class EyeTick extends Tick {

    public function new(X:Float,Y:Float,Callback:Void->Void) {
        super(X,Y,-45,Callback);

        var x = new FlxSprite(0,0,"assets/images/eye.png");
        stamp(x);
        
    }
}
class HandTick extends Tick {

    public function new(X:Float,Y:Float,Callback:Void->Void) {
        super(X,Y,45,Callback);

        var x = new FlxSprite(0,0,"assets/images/hand.png");
        stamp(x);
        
    }
}
