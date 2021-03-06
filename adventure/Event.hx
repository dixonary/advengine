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

class Event {

    public static var roomEvents:Map<Null<Room>,Array<EventTracker>> = new Map();

    public static function run(list:EventList, repeatable:Bool = true, ?persist:Bool = false) {

        if(list == []) return;
        var room = persist ? null : Global.currentRoom;

        var k = roomEvents.get(room);

        if(k == null) k = [];
        k.push({time:0,list:repeatable?list.copy():list});

        roomEvents.set(room,k);

    }

    public static function update(d) {
        for(room in roomEvents.keys()) {
            var lists = roomEvents.get(room);

            for(l in lists) {
                l.time+=d;
                for(e in l.list) {
                    if(e.time <= l.time) {
                        e.run();
                        l.list.remove(e);
                        if(l.list == [])
                            lists.remove(l);
                    }
                }
            }
        }
    }

    public static function removeAll(room:Room) {
        roomEvents.set(room, null);
    }

}

typedef EventTracker = {time:Float, list:EventList};

