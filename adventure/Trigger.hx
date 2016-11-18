package adventure;

using Reflect;
using Lambda;
using Type;
using Std;
using Characters;
using Speech;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
using StringTools;

class Trigger extends Object {

    public function new(X:Int) {
        super(X,0,"trigger");
        customName="";
    }

    public override function update(d):Void {
        super.update(d);
        if(pixelDistance(player) == 0)
            if(field("trigger") != null)
                callMethod(field("trigger"),[]);
    }

}
