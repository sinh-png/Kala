package kala;

import kala.Assets;
import kala.input.Keyboard;
import kala.input.Mouse;
import kala.input.Touch;
import kala.math.color.Color;
import kala.objects.Object;
import kala.objects.group.Group;
import kha.FastFloat;
import kha.Font;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Kala {
	
	/**
	 * Root group.
	 */
	public static var world(default, null):GenericGroup = new GenericGroup(false);
	
	/**
	 * How many times the game will be updated per second.
	 */
	public static var updateRate(default, set):UInt;
	
	/**
	 * How many times the game will be rendered per second.
	 * READ-ONLY
	 */
	public static var drawRate(get, null):Int;
	
	public static var fps(default, null):UInt;
	
	/**
	 * delta in seconds.
	 */
	public static var elapsedTime:FastFloat = 0;
	
	/**
	 * Elapsed time of successive frames in seconds when the game runs in perfect framerate.
	 */
	public static var perfectElapsedTime:FastFloat;
	 
	/**
	 * The last calculated delta / elapsed time of successive frames in milliseconds.
	 */
	public static var delta:Int = 0;
	
	/**
	 * If true, use milliseconds as timing unit otherwise use frames.
	 * DEFAULT: false
	 */
	public static var deltaTiming:Bool = false;

	/**
	 * The current screen width.
	 */
	public static var width(default, null):Int = 0;
	
	/**
	 * The current screen height.
	 */
	public static var height(default, null):Int = 0;

	public static var antiAliasingSamples(default, null):UInt;
	
	/**
	 * Background color.
	 */
	public static var bgColor:Color = 0xff000000;
	
	/**
	 * Default font used for text rendering.
	 */
	public static var defaultFont(default, set):Font;
	
	//
	
	private static var _updateTaskID:Null<Int>;
	private static var _lastUpdateTime:FastFloat = 0;
	
	/**
	 * Start the game.
	 * 
	 * @param	title			The windows title.
	 * @param	width			The width of the game window / screen.
	 * @param	height			The height of the game window / screen.
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
		
		width = screenWidth;
		height = screenHeight;
		
		System.init(
			{ 
				title: title, 
				width: width,
				height: height,
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
	
	/**
	 * Return a new value relative to the current game framerate.
	 */
	public static inline function applyDelta(value:FastFloat):FastFloat {
		return elapsedTime / perfectElapsedTime * value;
	}

	static function startWorld(updateRate:UInt):Void {
		#if (debug || kala_debug || kala_keyboard)
		Keyboard.init();
		#end
		
		#if (debug || kala_debug || kala_mouse)
		Mouse.init();
		#end
		
		#if kala_touch
		Touch.init();
		#end
	
		System.notifyOnRender(renderWorld);
		Kala.updateRate = updateRate;
	}
	
	static function renderWorld(framebuffer:Framebuffer):Void {
		width = framebuffer.width;
		height = framebuffer.height;
		
		framebuffer.g2.begin(true, bgColor);
		
		world.callDraw(new DrawingData(), framebuffer);
		
		#if (debug || kala_debug)
		Debug.draw(framebuffer);
		#end
		
		framebuffer.g2.end();
	}
	
	static function updateWorld():Void {
		var time = Scheduler.time();
		elapsedTime = time - _lastUpdateTime;
		_lastUpdateTime = time;
		
		fps = Math.round(1 / elapsedTime);

		delta = Std.int(elapsedTime * 1000);
		
		#if (debug || kala_debug || kala_keyboard)
		Keyboard.update(delta);
		#end
		
		#if (debug || kala_debug || kala_mouse)
		Mouse.update(delta);
		#end
		
		#if kala_touch
		Touch.update(delta);
		#end
	
		world.callUpdate(delta);
		
		Audio.update();
	}
	
	static function set_updateRate(value:UInt):UInt {
		perfectElapsedTime = 1 / value;
		
		if (_updateTaskID != null) {
			Scheduler.removeTimeTask(_updateTaskID);
		}
		
		_updateTaskID = Scheduler.addTimeTask(updateWorld, 0, 1 / value);

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