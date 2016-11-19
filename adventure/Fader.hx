package adventure;

import flixel.FlxG;
import flixel.FlxSprite;

class Fader extends FlxSprite {

    var fadeTime:Null<Float> = null;
    var fadeTarget:Null<Float> = null;

    public function new() {
        super();
        makeGraphic(FlxG.width, Game.ROOM_HEIGHT+ROOM_TOP*2);
        alpha = 0;
    }

    public function fadeIn(time:Float = 1) {
        fadeTime = time;
        fadeTarget = 0;
    }

    public funciton fadeOut(time:Float = 1) {
        fadeTime = time;
        fadeTarget = 1;
    }

    public function update(d) {
        visible = true;
        if(fadeTarget == 0) {
            alpha -= d/fadeTime;
            if(alpha <= 0){
                alpha = 0;
                done();
            }
        }
        else if(fadeTarget == 1) {
            alpha += d/fadeTime;
            if(alpha >= 1){
                alpha = 1;
                done();
            }
        }
    }

    public function done() {
        fadeTarget = null;
        fadeTime   = null;
    }

}
