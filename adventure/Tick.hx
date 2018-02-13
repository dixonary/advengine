package adventure;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
using flixel.util.FlxSpriteUtil;
using flixel.tweens.FlxTween;

class Tick extends FlxText {

    var TICK_OFFSET:Int = 64;
    static var ticks:Array<Tick> = [];

    var callback:Void->Void;

    var floatTime:Float = 0;
    var allowed:Bool = false;

    public function new(X:Float,Y:Float,Angle:Float,Word:String, Callback:Void->Void) {
        super();

        antialiasing = false;

        setFormat("assets/fonts/PIXELADE.TTF",40);
        text = Word;

        x = X;
        y = Y;


        x += Math.sin(Angle) * TICK_OFFSET - TICK_OFFSET/2;
        y -= Math.cos(Angle) * TICK_OFFSET;

        callback = Callback;

        setBorderStyle(OUTLINE,0xff000000,2);

        ticks.push(this);

        scale.set(0.1,0.1);
        scale.tween({x:1}, 0.2, {onComplete:function(t) {
            scale.tween({y:1}, 0.2, {onComplete:function(t) {
                allowed = true;
            }});
        }});

        floatTime += Math.random()*Math.PI*2;

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

        offset.y -= Math.sin(floatTime)*room.scaleFactor/2;
        floatTime += d*1.25;
        floatTime %= Math.PI*2;
        offset.y += Math.sin(floatTime)*room.scaleFactor/2;

        if(!allowed) return;

        if(
            Math.pow(FlxG.mouse.x-x-width/2,2) +
            Math.pow(FlxG.mouse.y-y-height/2,2) <
            TICK_SIZE/2*TICK_SIZE/2 ) {
            color = 0xff00ffff;

            if(FlxG.mouse.justPressed) {
                hit();
            }
        }
        else color = 0xffffffff;

    }

    function hit() {
        if(callback != null) {
            callback();
        }

        Tick.clear();

    }

}
