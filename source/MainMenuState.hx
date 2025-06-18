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
	public static var placeholderVersion:String = '0.0.1';
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

		var bg:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('menuBGBlue'));
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

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

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

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
									spr.kill();
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
		curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);
		menuItems.forEach(function(txt:FlxText) {
			txt.color = (txt.ID == curSelected) ? FlxColor.LIME : FlxColor.WHITE;
		});
	}
}