package;

import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

class OptionsMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<Option> = [
		new DFJKOption(controls),
		new NewInputOption(),
		new DownscrollOption(),
		new AccuracyOption(),
		new SongPositionOption(),
		#if !mobile
		new FPSOption(),
		#end
		new EtternaModeOption(),
		new ReplayOption()
	];

	var upP:Bool;
	var downP:Bool;
	var accepted:Bool;

	var scrollUp:Bool;
	var scrollDown:Bool;
	var scrollRight:Bool;
	var accept:Bool;
	var back:Bool;

	private var grpControls:FlxTypedGroup<Alphabet>;
	var versionShit:FlxText;
	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getDisplay(), true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}


		versionShit = new FlxText(5, FlxG.height - 18, 0, "Offset (Left, Right): " + FlxG.save.data.offset, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		upP = controls.UP_P;
		downP = controls.DOWN_P;
		accepted = controls.ACCEPT;

		scrollUp = false;
		scrollDown = false;
		scrollRight = false;
		accept = false;
		back = false;

		// The angle in degrees, between -180 and 180. 0 degrees points straight up.
		for (swipe in FlxG.swipes)
		{
			if(swipe.distance >= 25){
				if(swipe.angle >= -45 && swipe.angle <= 45)
					scrollDown = true;

				if(swipe.angle > -135 && swipe.angle < -45){
					back = true;
				}

				if(swipe.angle > 45 && swipe.angle < 135){
					scrollRight = true;
				}

				if((swipe.angle >= -180 && swipe.angle <= -135) || (swipe.angle >= 135 && swipe.angle <= 180))
					scrollUp = true;
			}
			else
				accept = true;
		}

			if (controls.BACK || back)
				FlxG.switchState(new MainMenuState());
			if (controls.UP_P || scrollUp)
				changeSelection(-1);
			if (controls.DOWN_P || scrollDown)
				changeSelection(1);
			
			if (controls.RIGHT_R || scrollRight)
			{
				FlxG.save.data.offset++;
				versionShit.text = "Offset (Left, Right): " + FlxG.save.data.offset;
			}

			if (controls.LEFT_R)
				{
					FlxG.save.data.offset--;
					versionShit.text = "Offset (Left, Right): " + FlxG.save.data.offset;
				}
	

			if (controls.ACCEPT || accept)
			{
				if (options[curSelected].press()) {
					grpControls.remove(grpControls.members[curSelected]);
					var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, options[curSelected].getDisplay(), true, false);
					ctrl.isMenuItem = true;
					grpControls.add(ctrl);
				}
			}
		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent("Fresh");
		#end
		
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
