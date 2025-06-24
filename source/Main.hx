package;

#if desktop
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#end

import debug.FPS;

#if (linux && !debug)
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end
class Main extends openfl.display.Sprite
{
	public final config:Dynamic = {
		gameDimensions: [1280, 720],
		initialState: TitleState,
		defaultFPS: 60,
		skipSplash: true,
		startFullscreen: false
	};

	public static var fpsVar:FPS;

	public static function main():Void
		Lib.current.addChild(new Main());

	#if desktop
	static function __init__():Void {
		var origin:String = #if hl Sys.getCwd() #else Sys.programPath() #end;

		var configPath:String = Path.directory(Path.withoutExtension(origin));
		#if windows
		configPath += "/alsoft.ini";
		#elseif mac
		configPath = Path.directory(configPath) + "/Resources/alsoft.conf";
		#else
		configPath += "/alsoft.conf";
		#end

		Sys.putEnv("ALSOFT_CONF", configPath);
	}
	#end

	public function new()
	{
		super();

		#if windows
		WindowsAPI.darkMode(true);
		#end

		FlxG.save.bind('funkin', 'ninjamuffin99');
		Highscore.load();

		#if VIDEOS_ALLOWED
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0")  ['--no-lua'] #end);
		#end
	
		ClientPrefs.loadDefaultKeys();
		addChild(new FlxGame(config.gameDimensions[0], config.gameDimensions[1], config.initialState, config.defaultFPS, config.defaultFPS, config.skipSplash, config.startFullscreen));

		fpsVar = new FPS(10, 10, 0xFFFFFF);
		addChild(fpsVar);
		if(fpsVar != null)
			fpsVar.visible = ClientPrefs.showFPS;

		#if (linux || mac)
		Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile("icon.png"));
		#end

		#if html5
		FlxG.autoPause = FlxG.mouse.visible = false;
		#end

		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, (e) -> {
			var errMsg:String = "";
			var path:String;
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);
			var dateNow:String = Date.now().toString();
	
			dateNow = dateNow.replace(" ", "_");
			dateNow = dateNow.replace(":", "'");
	
			path = "./crash/" + "VSRob_" + dateNow + ".txt";
	
			for (stackItem in callStack)
			{
				switch (stackItem)
				{
					case FilePos(s, file, line, column):
						errMsg += file + " (line " + line + ")\n";
					default:
						Sys.println(stackItem);
				}
			}
	
			errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/Joalor64GH/VS-Rob-Rebooted/issues\n\n> Crash Handler written by: sqirra-rng";
	
			if (!FileSystem.exists("./crash/"))
				FileSystem.createDirectory("./crash/");
	
			File.saveContent(path, errMsg + "\n");
	
			Sys.println(errMsg);
			Sys.println("Crash dump saved in " + Path.normalize(path));
	
			Application.current.window.alert(errMsg, "Error!");
			DiscordClient.shutdown();
			Sys.exit(1);
		});
		#end

		#if desktop
		if (!DiscordClient.isInitialized)
		{
			DiscordClient.initialize();
			Application.current.window.onClose.add(function() {
				if (DiscordClient.isInitialized)
					DiscordClient.shutdown();
			});
		}
		#end
	}
}