package;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<FlxText>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [
			['Psych Engine Team'],
			['ShadowMario', 'shadowmario', 'Main Programmer of Psych Engine', 'https://twitter.com/Shadow_Mario_', '444444'],
			['Riveren', 'riveren', 'Main Artist/Animator of Psych Engine', 'https://twitter.com/riverennn', '14967B'],
			[''],
			['Former Engine Members'],
			['bbpanzu', 'bb', 'Ex-Programmer of Psych Engine', 'https://twitter.com/bbsub3', '3E813A'],
			[''],
			['Engine Contributors'],
			['iFlicky', 'flicky', 'Composer of Psync and Tea Time\nMade the Dialogue Sounds', 'https://twitter.com/flicky_i', '9E29CF'],
			['gedehari', 'sqirra', 'Crash Handler and Base code for\nChart Editor\'s Waveform', 'https://twitter.com/gedehari', 'E1843A'],
			['crowplexus', 'crowplexus', 'Contributor', 'https://github.com/crowplexus', 'a1a1a1'],
			['TahirKarabekiroglu', 'tahir', 'Contributor', 'https://github.com/TahirKarabekiroglu', 'A04397'],
			['EliteMasterEric', 'mastereric', 'Runtime Shaders support', 'https://twitter.com/EliteMasterEric', 'FFBD40'],
			['PolybiusProxy', 'proxy', 'Creator of hxCodec', 'https://twitter.com/polybiusproxy', 'DCD294'],
			['KadeDev', 'kade', 'Fixed Chart Editor and other PRs\nExtension WebM Fork', 'https://twitter.com/kade0912', '64A250'],
			['Keoiki', 'keoiki', 'Note Splash Animations\nLatin Support', 'https://twitter.com/Keoiki_', 'D2D2D2'],
			['Nebula the Zorua', 'nebula', 'Contributor', 'https://twitter.com/Nebula_Zorua', '7D40B2'],
			['Smokey', 'smokey', 'Sprite Atlas Support', 'https://twitter.com/Smokey_5_', '483D92'],
			[''],
			["The Funkin' Crew Inc"],
			['ninjamuffin99', 'ninjamuffin99', "Programmer/Creator of Friday Night Funkin'", 'https://twitter.com/ninja_muffin99', 'CF2D2D'],
			['PhantomArcade', 'phantomarcade', "Animator of Friday Night Funkin'", 'https://twitter.com/PhantomArcade3K', 'FADC45'],
			['evilsk8r', 'evilsk8r', "Artist of Friday Night Funkin'", 'https://twitter.com/evilsk8r', '5ABD4B'],
			['kawaisprite', 'kawaisprite', "Composer of Friday Night Funkin'", 'https://twitter.com/kawaisprite', '378FC7']
	];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:FlxColor;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var camFollow:FlxObject;

	var offsetThing:Float = -75;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();

		camFollow = new FlxObject(80, 0, 0, 0);
		camFollow.screenCenter(X);
		add(camFollow);
		
		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);
	
		for (i in 0...creditsStuff.length)
		{
			var text:FlxText = new FlxText(20, 60 + (i * 80), creditsStuff[i][0], 32);
			text.setFormat(Paths.font('android.ttf'), 60, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.ID = i;
			grpOptions.add(text);

			if(unselectableCheck(i)) {
				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = text.width + 10;
				icon.sprTracker = text;
				iconArray.push(icon);
				add(icon);
			}
		}
		
		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		descText.scrollFactor.set();
		descBox.sprTracker = descText;
		add(descText);

		bg.color = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		intendedColor = bg.color;
		changeSelection();
		FlxG.camera.follow(camFollow, null, 0.15);
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-1 * shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(1 * shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}

			if(controls.ACCEPT) {
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}
			if (controls.BACK)
			{
				if(colorTween != null)
					colorTween.cancel();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
		
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected = FlxMath.wrap(curSelected + change, 0, creditsStuff.length - 1);
		} while(unselectableCheck(curSelected));

		var newColor:FlxColor = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		trace('The BG color is: $newColor');
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		grpOptions.forEach(function(txt:FlxText)
		{
			txt.alpha = (curSelected == txt.ID) ? 1 : 0.6;
			if (txt.ID == curSelected)
				camFollow.y = txt.y;
		});

		descText.text = creditsStuff[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}