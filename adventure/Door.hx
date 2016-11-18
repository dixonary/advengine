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

class Door extends Object {

    var newRoom:String="";
    var newPlayerX:Int=0;
    var newPlayerY:Int=0;
    var touched:Bool = false;
    var lockedText:String = "It's locked.";
    public var locked:Bool = false;

    public function new(x,y,?asset:String) {
        super(x,y);
        hideName = true;
    }

    public override function update(d):Void {
        super.update(d);
    }

    function use() {
        if(pixelDistance(player) > 0) {
            player.say("I'm too far away from the door.");
        }
        else {
            if(locked) player.say(lockedText);
            else go();
        }
    }

    function go() {
        if(newRoom=="" || (newPlayerX==0&&newPlayerY==0)) {
            throw "Not enough information to change room!";
        }
        cast(FlxG.state,Game).switchRoom(newRoom,newPlayerX,newPlayerY);
    }

}
