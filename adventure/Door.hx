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

class Door extends Object {

    var newRoom:Class<Room>;
    var newPlayerX:Int=-1;
    var newPlayerY:Int=-1;
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

    override function use() {
        go();
    }

    function go() {
        if (newRoom==null){
            throw "new room not set on door!";
        }
        if (newPlayerX==-1 && newPlayerY==-1) {
            throw "X or Y not set on room!";
        }
        game.switchRoom(newRoom,newPlayerX,newPlayerY);
    }

}
