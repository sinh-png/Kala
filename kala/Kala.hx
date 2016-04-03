package kala;

import kala.input.Keyboard;
import kala.input.Mouse;
import kala.math.Color;
import kala.objects.Object;
import kala.objects.group.Group;
import kha.Assets;
import kha.FastFloat;
import kha.Font;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.arrays.Float32Array;

@:access(kala.objects.Object)
class Kala {

	/**
	 * Root group.
	 */
	public static var world(default, null):Group<Object> = new Group<Object>(true);
	
	/**
	 * How many times the game will be updated per second.
	 */
	public static var updateRate(default, set):UInt;
	
	/**
	 * How many times the game will be rendered per second.
	 * READ-ONLY
	 */
	public static var drawRate(get, null):Int;
	
	public static var fps(default, null):Int;
	
	/**
	 * The unit used for timing. 
	 * DEFAULT: FRAME
	 */
	public static var timingUnit:TimeUnit = TimeUnit.FRAME;
	
	public static var antiAliasingSamples(default, null):UInt;
	
	public static var bgColor(default, null):Color = new Color(1, 0x000000);
	
	public static var defaultFont(default, set):Font;
	
	//
	
	private static var _updateTaskID:Null<Int>;
	private static var _lastUpdateTime:FastFloat = 0;
	
	/**
	 * Start the game.
	 * 
	 * @param	title			The windows title.
	 * @param	screenWidth		The width of the game window / screen.
	 * @param	screenHeight	The height of the game window / screen.
	 * @param 	updateRate		How many times the game will be updated per second.
	 * @param	loadAllAssets	If true, load all assets.
	 */
	public static function start(
		?title:String = "Hello!",
		?screenWidth:UInt = 800, ?screenHeight:UInt = 600,
		?antiAliasingSamples:UInt = 1,
		?updateRate:UInt = 60,
		?loadAllAssets:Bool = true
	):Void {
		Kala.antiAliasingSamples = antiAliasingSamples;
		
		System.init(
			{ 
				title: title, 
				width: screenWidth,
				height: screenHeight,
				samplesPerPixel: antiAliasingSamples
			},
			function() {			
				if (loadAllAssets) {
					Assets.loadEverything(
						function() startWorld(updateRate)
					);
				} else startWorld(updateRate);
			}
		);
	}
	
	static function startWorld(updateRate:UInt):Void {
		Keyboard.init();
		Mouse.init();

		System.notifyOnRender(renderWorld);
		Kala.updateRate = updateRate;
	}
	
	static function renderWorld(framebuffer:Framebuffer):Void {
		framebuffer.g2.begin(true, bgColor.argb());
		world.callDraw(new DrawingData(), framebuffer);
		framebuffer.g2.end();
	}
	
	static function updateWorld():Void {
		var time = Scheduler.time();
		var delta = time - _lastUpdateTime;
		_lastUpdateTime = time;
		
		fps = Math.ceil(1 / delta);
		
		Keyboard.onPreUpdate();
		Mouse.onPreUpdate();
		
		world.callUpdate(delta);
		
		Keyboard.onPostUpdate();
		Mouse.onPostUpdate();
	}
	
	static function set_updateRate(value:UInt):UInt {
		if (_updateTaskID != null) {
			Scheduler.removeTimeTask(_updateTaskID);
		}
		
		Scheduler.addTimeTask(updateWorld, 0, 1 / value);
		
		return updateRate = value;
	}
	
	static function get_drawRate():UInt {
		return System.refreshRate;
	}
	
	static function set_defaultFont(value:Font):Font {
		if (value == null) return null;
		return defaultFont = value;
	}

}

enum TimeUnit {
	FRAME;
	MILLISECOND;
}