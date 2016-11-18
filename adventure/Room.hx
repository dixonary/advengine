package adventure;

import flixel.FlxG;
using Reflect;
using Type;
using Std;
using Lambda;

class Room extends Object {

    public var objects:Array<Object> = [];
    public var scaleFactor:Int = Game.SCALE_FACTOR;

    public function new() {
        super(0,0);
        layer = ROOM;
    }

    public function create() {}

    public function getX(X) {
        return FlxG.width/2 - width/2
            + X * scaleFactor;
    }
    public function getY(Y) {
        return Game.ROOM_HEIGHT/2 - height/2
            + Y * scaleFactor;
    }

    public function v_leave() {
        for(o in objects) {
            cast(FlxG.state,Game).layers.get(o.layer).remove(o);
            o.clearSpeeches();
        }
        if(field("leave") != null)
            callMethod(field("leave"), []);

    }

    public function v_enter() {
        for(o in objects) {
            cast(FlxG.state,Game).layers.get(o.layer).add(o);
        }
        if(field("enter") != null)
            callMethod(field("enter"), []);
    }

    override function roomPos(X:Float,Y:Float) {
        return {x:FlxG.width/2-width/2,
            y:Game.ROOM_HEIGHT/2-height/2+Game.ROOM_TOP};
    }

    public function get(O:Class<Object>):Dynamic {
        var k = objects.find(function(o){return o.getClass() == O;});
        if(k == null) throw ("no object "+O+" in room!");
        return k;
    }

    public function addObject(O:Object) {
        objects.push(O);
    }

    public function remObject(O:Object) {
        objects.remove(O);
        O.destroy();
    }

}
