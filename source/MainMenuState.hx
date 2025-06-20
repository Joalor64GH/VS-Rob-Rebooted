package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var placeholderVersion:String = '0.1.0';
	public static var psychEngineVersion:String = '0.5.2h';
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxText>;
	var optionShit:Array<String> = [
		'STORY MODE',
		'FREEPLAY',
		'CREDITS',
		'OPTIONS'
	];

	var debugKeys:Array<FlxKey>;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('mainmenu/bg_interface'));
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(0, 40);
		add(grid);

		var menuCover:FlxSprite = new FlxSprite().makeGraphic(FlxG.width - 500, Std.int(FlxG.height));
		menuCover.color = FlxColor.WHITE;
		menuCover.screenCenter(X);
		add(menuCover);

		var menuCoverAlt:FlxSprite = new FlxSprite().makeGraphic(Std.int(menuCover.width - 20), Std.int(menuCover.height));
		menuCoverAlt.setPosition(menuCover.x + 10, menuCover.y);
		menuCoverAlt.color = FlxColor.BLACK;
		add(menuCoverAlt);

		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var text:FlxText = new FlxText(0, 230 + (i * 70), 0, optionShit[i], 32);
			text.setFormat(Paths.font('android.ttf'), 80, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.scrollFactor.set();
			text.screenCenter(X);
			text.ID = i;
			menuItems.add(text);
		}

		var versionShitArray:Array<String> = [
			'VS Rob Rebooted is owned by Joalor64 and any affiliates.',
			'Placeholder Engine v$placeholderVersion (Psych Engine v$psychEngineVersion)',
			"Friday Night Funkin' v" + Application.current.meta.get('version')
		];
		versionShitArray.reverse();
		for (i in 0...versionShitArray.length) {
			var versionShit:FlxText = new FlxText(12, (FlxG.height - 24) - (18 * i), 0, versionShitArray[i], 12);
			versionShit.scrollFactor.set();
			versionShit.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(versionShit);
		}

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(txt:FlxText)
					{
						if (curSelected != txt.ID)
						{
							FlxTween.tween(txt, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									txt.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(txt, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								switch (curSelected)
								{
									case 0:
										MusicBeatState.switchState(new StoryMenuState());
									case 1:
										MusicBeatState.switchState(new FreeplayState());
									case 2:
										MusicBeatState.switchState(new CreditsState());
									case 3:
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + huh, 0, optionShit.length - 1);
		menuItems.forEach(function(txt:FlxText) {
			txt.color = (txt.ID == curSelected) ? FlxColor.CYAN : FlxColor.WHITE;
		});
	}
}