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

class Block extends Object {

    public function new(X:Int) {
        super(X,0,"block");
        customName="";
        immovable = true;
        visible = false;
    }

    public override function update(d):Void {
        super.update(d);
        FlxG.collide(this,game.layers.get(CHAR));
    }

}
