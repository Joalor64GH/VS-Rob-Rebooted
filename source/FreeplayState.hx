package;

class FreeplayState extends MusicBeatState 
{
    	private var grpControls:FlxTypedGroup<Alphabet>;
        private var grpIcons:FlxTypedGroup<HealthIcon>;

	public var controlStrings:Array<CoolSong> = [
		new CoolSong('Tutorial', 'woah', 'gf')
	];
	
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var scoreText:FlxText;
	var descTxt:FlxText;

	var bottomPanel:FlxSprite;

	var menuBG:FlxSprite;

    	var curSelected:Int = 0;

		var missingText:FlxText;
	var missingTextBG:FlxSprite;

    	override function create()
	{
		controlStrings.push(new CoolSong('Test', 'omg real??', 'bf-pixel'));

		menuBG = new FlxSprite().loadGraphic(Paths.image('mainmenu/bg_msn'));
        	menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(menuBG);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

        	var slash:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/slash'));
		slash.antialiasing = ClientPrefs.globalAntialiasing;
		slash.screenCenter();
		add(slash);

        	grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);
		grpIcons = new FlxTypedGroup<HealthIcon>();
		add(grpIcons);

		for (i in 0...controlStrings.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, controlStrings[i].name, true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i - curSelected;
			grpControls.add(controlLabel);

            		var icon:HealthIcon = new HealthIcon(controlStrings[i].icon);
			icon.sprTracker = controlLabel;
			icon.updateHitbox();
			add(icon);
			icon.ID = i;
			grpIcons.add(icon);
		}
        
        	bottomPanel = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		bottomPanel.alpha = 0.5;
		add(bottomPanel);

        	scoreText = new FlxText(20, FlxG.height - 80, 1000, "", 22);
		scoreText.setFormat(Paths.font("vcr.ttf"), 30, 0xFFffffff, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.scrollFactor.set();
        	scoreText.screenCenter(X);
        	add(scoreText);

        	descTxt = new FlxText(scoreText.x, scoreText.y + 36, 1000, "", 22);
        	descTxt.screenCenter(X);
		descTxt.scrollFactor.set();
		descTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(descTxt);

		var topPanel:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 26, FlxColor.BLACK);
		topPanel.scrollFactor.set();
		topPanel.alpha = 0.6;
		add(topPanel);

		var controlsTxt:FlxText = new FlxText(topPanel.x, topPanel.y + 4, FlxG.width, "R - RESET SCORE // CTRL - GAMEPLAY CHANGERS // ALT - REPLAYS", 32);
		controlsTxt.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		controlsTxt.screenCenter(X);
		controlsTxt.scrollFactor.set();
		add(controlsTxt);

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

        	changeSelection();

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        	lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		
		if(ratingSplit.length < 2)
			ratingSplit.push('');
		while(ratingSplit[1].length < 2)
			ratingSplit[1] += '0';

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';

        	if (controls.UI_UP_P || controls.UI_DOWN_P)
			changeSelection(controls.UI_UP_P ? -1 : 1);

		if (controls.BACK) 
        	{
                	FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
        	}
            
		if (controls.ACCEPT)
		{
            		FlxG.sound.music.volume = 0;
            		FlxG.sound.play(Paths.sound('confirmMenu'));
			var lowercasePlz:String = Paths.formatToSongPath(controlStrings[curSelected].name);
			var formatIdfk:String = Highscore.formatSong(lowercasePlz);
			try 
			{
				LoadingState.loadAndSwitchState(new PlayState());
				PlayState.SONG = Song.loadFromJson(formatIdfk);
				PlayState.isStoryMode = false;
			} 
			catch(e:Dynamic)
				{
					trace('ERROR! $e');

					var errorStr:String = e.toString();
					if (errorStr.startsWith('[lime.utils.Assets] ERROR:')) errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(lowercasePlz), errorStr.length - 1);
					missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
					missingText.screenCenter(Y);
					missingText.visible = true;
					missingTextBG.visible = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));

					super.update(elapsed);
					return;
				}
		}

        	if (FlxG.keys.justPressed.CONTROL)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if (controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(controlStrings[curSelected].name, controlStrings[curSelected].icon));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		#if sys
		else if (FlxG.keys.justPressed.ALT)
			MusicBeatState.switchState(new ReplaySelectState(controlStrings[curSelected].name));
		#end
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		descTxt.text = controlStrings[curSelected].desc;

		var bullShit:Int = 0;

        	intendedScore = Highscore.getScore(controlStrings[curSelected].name);
		intendedRating = Highscore.getRating(controlStrings[curSelected].name);

		for (i in grpIcons.members) i.alpha = (i.ID == curSelected ? 1 : 0.6);

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}
}

class CoolSong
{
	public var name:String = '';
	public var desc:String = '';
	public var icon:String = '';

	public function new(name:String, desc:String, icon:String)
	{
		this.name = name;
        	this.desc = desc;
        	this.icon = icon;
	}
}