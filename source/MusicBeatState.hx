package;

import Conductor.BPMChangeEvent;
import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		super.create();

		if (!FlxTransitionableState.skipNextTransOut) {
			var cam:FlxCamera = new FlxCamera();
			cam.bgColor.alpha = 0;
			FlxG.cameras.add(cam, false);
			cam.fade(FlxColor.BLACK, 0.7, true, function() {
				FlxTransitionableState.skipNextTransOut = false;
			});
		} else
			FlxTransitionableState.skipNextTransOut = false;
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		if(FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;

		#if debug
		if (FlxG.keys.justPressed.F5)
			FlxG.resetState();
		#end

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor(((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / Conductor.stepCrochet);
	}

	public static function switchState(nextState:FlxState) {
		if (!FlxTransitionableState.skipNextTransIn) {
			var cam:FlxCamera = new FlxCamera();
			cam.bgColor.alpha = 0;
			FlxG.cameras.add(cam, false);
			cam.fade(FlxColor.BLACK, 0.7, false, function() {
				FlxG.switchState(nextState);
				FlxTransitionableState.skipNextTransIn = false;
			});
		} else {
			FlxG.switchState(nextState);
			FlxTransitionableState.skipNextTransIn = false;
		}
	}

	public static function resetState() {
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
