package adventure;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
using flixel.util.FlxSpriteUtil;

class Tick extends FlxText {

    var TICK_SIZE:Int = 64;
    var TICK_OFFSET:Int = 64;
    static var ticks:Array<Tick> = [];

    var callback:Void->Void;

    public function new(X:Float,Y:Float,Angle:Float,Word:String, Callback:Void->Void) {
        super();

        antialiasing = false;

        setFormat("assets/fonts/PIXELADE.TTF",40);
        text = Word;

        x = X;
        y = Y;

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
