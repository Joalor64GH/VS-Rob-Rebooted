package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var bg:FlxSprite;
	var bgCity:FlxSprite;
	var stars:FlxTypedGroup<FlxSprite>;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var isMe:FlxSprite;
	var logo:FlxSprite;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	var curWacky:Array<String> = [];

	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		super.create();

		if (!initialized) {
			ClientPrefs.loadPrefs();
			Colorblind.updateFilter();
		}

		if(!initialized && FlxG.save.data != null && FlxG.save.data.fullscreen)
		{
			FlxG.fullscreen = FlxG.save.data.fullscreen;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;

		if (FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else
			startIntro();
	}

	function startIntro()
	{
		if (!initialized && FlxG.sound.music == null)
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

		Conductor.bpm = 102.0;
		persistentUpdate = true;

		bg = new FlxSprite().loadGraphic(Paths.image('title/bg_cityscape'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.screenCenter();

		stars = new FlxTypedGroup<FlxSprite>();

		bgCity = new FlxSprite().loadGraphic(Paths.image('title/title_city'));
		bgCity.antialiasing = ClientPrefs.globalAntialiasing;
		bgCity.screenCenter();

		logo = new FlxSprite().loadGraphic(Paths.image('title/titleLogo'));
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		logo.scale.set(0.8, 0.8);
		logo.updateHitbox();
		logo.screenCenter();

		add(bg);
		add(stars);
		for (i in 0...100) {
			var star = new FlickeringStar(FlxG.random.float(0, FlxG.width), FlxG.random.float(0, FlxG.height));
			stars.add(star);
		}
		add(bgCity);
		add(logo);

		if (ClientPrefs.shaders) {
			swagShader = new ColorSwap();
			if (swagShader != null) {
				bg.shader = swagShader.shader;
				bgCity.shader = swagShader.shader;
				logo.shader = swagShader.shader;
			}
		}

		titleText = new FlxSprite(130, 576);
		#if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/title/titleEnter.png";
		if (!FileSystem.exists(path)){
			path = "mods/images/title/titleEnter.png";
		}
		if (!FileSystem.exists(path)){
			path = "assets/images/title/titleEnter.png";
		}
		titleText.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path),File.getContent(StringTools.replace(path,".png",".xml")));
		#else
		
		titleText.frames = Paths.getSparrowAtlas('title/titleEnter');
		#end
		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}

		if (animFrames.length > 0) {
			newTitle = true;

			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else {
			newTitle = false;

			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;

		isMe = new FlxSprite(0, FlxG.height * 0.50).loadGraphic(Paths.image('title/joalor64Icon'));
		add(isMe);
		isMe.visible = false;
		isMe.scale.set(0.35, 0.35);
		isMe.updateHitbox();
		isMe.screenCenter(X);
		isMe.antialiasing = ClientPrefs.globalAntialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		
		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.fadeOut(0.3);
			FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
			{
				#if sys
				Sys.exit(0);
				#else
				System.exit(0);
				#end
			}, false);
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		if (newTitle) {
			titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;

				timer = FlxEase.quadInOut(timer);

				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}

			if(pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;
				
				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new MainMenuState());
					closedState = true;
				});
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null && ClientPrefs.shaders)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
			money.y -= 350;
			FlxTween.tween(money, {y: money.y + 350}, 0.5, {ease: FlxEase.expoOut, startDelay: 0.0});
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
			coolText.y += 750;
			FlxTween.tween(coolText, {y: coolText.y - 750}, 0.5, {ease: FlxEase.expoOut, startDelay: 0.0});
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		FlxTween.tween(FlxG.camera, {zoom:1.03}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					FlxG.sound.music.fadeIn(4, 0, 0.7);
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				case 2:
					createCoolText(['Psych Engine by']);
				case 4:
					addMoreText('ShadowMario');
					addMoreText('Riveren');
				case 5:
					deleteCoolText();
				case 6:
					createCoolText(['Brought to you by']);
				case 8:
					addMoreText('Yours Truly');
					isMe.visible = true;
					isMe.scale.set(0.45, 0.45);
					FlxTween.cancelTweensOf(isMe.scale);
					FlxTween.tween(isMe.scale, {x: 0.35, y: 0.35}, 0.3, {ease: FlxEase.quadOut});
				case 9:
					deleteCoolText();
					isMe.visible = false;
				case 10:
					createCoolText([curWacky[0]]);
				case 12:
					addMoreText(curWacky[1]);
				case 13:
					deleteCoolText();
				case 14:
					addMoreText('Friday Night Funkin');
				case 15:
					addMoreText('VS Rob');
				case 16:
					addMoreText('REBOOTED!');

				case 17:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(isMe);
			remove(credGroup);
			FlxG.camera.flash(FlxColor.WHITE, 4);

			logo.angle = -4;

			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				if (logo.angle == -4)
					FlxTween.angle(logo, logo.angle, 4, 4, {ease: FlxEase.quartInOut});
				if (logo.angle == 4)
					FlxTween.angle(logo, logo.angle, -4, 4, {ease: FlxEase.quartInOut});
			}, 0);

			skippedIntro = true;
		}
	}
}

class FlickeringStar extends FlxSprite {
	public function new(x:Float, y:Float) {
		super(x, y);
		var size:Int = FlxG.random.int(1, 3);
		makeGraphic(size, size, FlxColor.WHITE);
		alpha = FlxG.random.float(0.3, 1);
		startFlicker();
	}

	private function startFlicker():Void {
		new FlxTimer().start(FlxG.random.float(0.5, 2), function(_) {
			var newAlpha:Float = FlxG.random.float(0.3, 1);
			FlxTween.tween(this, {alpha: newAlpha}, 0.5, {
				onComplete: function(_) {
					startFlicker();
				}
			});
		});
	}
}