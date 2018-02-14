package adventure;

import openfl.net.URLRequest;
import openfl.Lib;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup;
import flixel.tweens.*;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;

using flixel.tweens.FlxTween;
using flixel.util.FlxSpriteUtil;

class Menu extends FlxSpriteGroup {

    var showing:Bool = false;

    public var menuWidth:Int = cast FlxG.width/2;
    public var menuHeight:Int = cast FlxG.height/2;
    public var numOptions:Int = 8;

    public var interactable:Bool = false;

    public function new() {
        super();

        var bg = new FlxSprite(0,0,"assets/images/cutscene.png");
        bg.origin.set(0,0);
        bg.scale.set(8,8);
        add(bg);

        makeOption(4,0,1,0.5,"Twitter", function() {

            var path = "https://twitter.com/Jackaphobia";
#if windows
            Sys.command ("start", [ path ]);
#elseif mac
            Sys.command ("/usr/bin/open", [ path ]);
#elseif linux
            Sys.command ("/usr/bin/xdg-open", [ path ]);
#end
        });
        makeOption(4,0.5,1,0.5,"Exit", function() {
            Sys.exit(0);
        });
        makeOption(3,0,1,1,"Toggle Fullscreen", function() {
            FlxG.fullscreen = !FlxG.fullscreen;
        });

        //y = -FlxG.height;
        alpha = 0.00001;

        y = -FlxG.height*2;
    }

    public function show() {
        if(showing) return;
        showing = true;
        Global.canInteract = false;
        visible = true;
        tween({alpha:1}, 0.4, {onComplete:function(t) {
            interactable = true;
        }});
        y = 0;
    }

    public function hide() {
        if(!showing) return;
        showing = false;
        interactable = false;
        tween({alpha:0.00001}, 0.4, {onComplete:function(t) {
            Global.canInteract = true;
            y = -FlxG.height*2;
        }});
    }

    public function toggle() {
        if(interactable) {
            hide();
        }
        if(Global.canInteract) {
           show();
        }
    }

    public function makeOption(StartRow:Float,StartCol:Float, Rows:Float,Cols:Float,
            Word,Callback) {

        var top = (FlxG.height-menuHeight)/2;
        var left = (FlxG.width - menuWidth) /2;

        var opt = new MenuButton(
            left + menuWidth * StartCol,
            top + menuHeight * StartRow / numOptions,
            Std.int(Math.floor(menuWidth * Cols)),
            Std.int(Math.floor(menuHeight * Rows / numOptions)),
            Word, Callback);

        add(opt);

    }
    public function addOption(o:MenuButton) {
        add(o);
    }

}

class MenuButton extends FlxSpriteGroup {

    var callback:Void->Void;
    var text:FlxText;
    var bg:FlxSprite;
    var primcolor:Int = 0xff848482;

    public function new(X:Float,Y:Float,W:Int,H:Int,Word:String,Callback) {
        super();

        bg = new FlxSprite();
        bg.makeGraphic(W,H,0x00000000,true);
        bg.drawRect(Std.int(Global.defaultScaleFactor/2),
                 Std.int(Global.defaultScaleFactor/2),
                 W-Global.defaultScaleFactor,
                 H-Global.defaultScaleFactor,
                 0x55000000,
                {thickness:Std.int(Global.defaultScaleFactor/2),color:primcolor,jointStyle:MITER,
                    pixelHinting:true});

        bg.antialiasing=true;

        bg.x = X;
        bg.y = Y;

        add(bg);

        text = new FlxText(0,0,W-Global.defaultScaleFactor*2,Word);
        add(text);

        text.setFormat("assets/fonts/PIXELADE.TTF",Std.int(H/3*2),0xffffffff);
        text.alignment = CENTER;
        text.x = X + Global.defaultScaleFactor;
        text.y = Y + Global.defaultScaleFactor;
        text.setBorderStyle(OUTLINE,0xff000000,2);

        callback = Callback;

    }

    override public function update(d) {
        super.update(d);

        if(Game.menu != null && !Game.menu.interactable)
            return;

        if(FlxG.mouse.getWorldPosition().inCoords(
                bg.x,bg.y,bg.width,bg.height)){
            if(FlxG.mouse.justPressed)
                callback();
            text.color = 0xffff00ff;
        }
        else {
            text.color = 0xffffffff;
        }
    }

}
