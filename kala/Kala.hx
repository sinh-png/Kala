package kala;

import kala.asset.Assets;
import kala.audio.Audio;
import kala.debug.Debug;
import kala.input.Keyboard;
import kala.input.Mouse;
import kala.input.Touch;
import kala.math.color.Color;
import kala.objects.group.View;
import kala.objects.Object;
import kala.objects.group.Group;
import kha.FastFloat;
import kha.Font;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.SystemImpl;

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
	 * Delta value when the game runs in perfect framerate.
	 */
	public static var perfectDelta:FastFloat;
	 
	/**
	 * Elapsed time of two last successive frames in seconds.
	 */
	public static var delta:FastFloat = 0;
	
	/**
	 * If true, use seconds for calculating timestep otherwise use frames. 
	 * Timestep is still affected by timeScale when this set to false.
	 * 
	 * DEFAULT: false
	 */
	public static var deltaTiming:Bool = false;
	
	/**
	 * Scale factor to calculate elapsed time. This affects all built-in timing processes of objects and behaviors. 
	 */
	public static var timeScale:FastFloat = 1;

	/**
	 * The current screen width.
	 */
	public static var width(default, null):Int = 0;
	
	/**
	 * The current screen height.
	 */
	public static var height(default, null):Int = 0;

	/**
	 * Background color.
	 */
	public static var bgColor:Color = 0xff000000;
	
	/**
	 * Default font used for text rendering.
	 */
	public static var defaultFont(default, set):Font;
	
	
	/**
	 * Default view used to calculate mouse & touch position.
	 */
	public static var defaultView:View;
	
	//
	
	#if js
	public static var html5(default, never):kala.system.HTML5 = new kala.system.HTML5();
	#end
	
	//
	
	private static var _updateTaskID:Null<Int>;
	private static var _prvUpdateTime:FastFloat = 0;
	
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
		return delta / perfectDelta * value;
	}
	
	
	public static inline function openURL(url:String, ?target:String = "_blank"):Void {
		#if js
		js.Browser.window.open(url, target);
		#elseif flash
		flash.Lib.getURL(new flash.net.URLRequest(url), target);
		#end
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
		
		world.callDraw(new DrawingData(false, null, null, null, null, 1, null), framebuffer);
		
		#if (debug || kala_debug)
		Debug.draw(framebuffer);
		#end
		
		framebuffer.g2.end();
	}
	
	static function updateWorld():Void {
		var time = Scheduler.time();
		delta = time - _prvUpdateTime;
		_prvUpdateTime = time;
		
		fps = Math.round(1 / delta);

		var elapsed = deltaTiming ? delta * timeScale : timeScale;
		
		#if (debug || kala_debug || kala_keyboard)
		Keyboard.update(elapsed);
		#end
		
		#if (debug || kala_debug || kala_mouse)
		Mouse.update(elapsed);
		#end
		
		#if kala_touch
		Touch.update(elapsed);
		#end
	
		world.callUpdate(elapsed);
		
		Audio.update();
	}
	
	static function set_updateRate(value:UInt):UInt {
		perfectDelta = 1 / value;
		
		if (_updateTaskID != null) {
			Scheduler.removeTimeTask(_updateTaskID);
		}
		
		_updateTaskID = Scheduler.addTimeTask(updateWorld, 0, 1 / value);

		return updateRate = value;
	}
	
	static inline function get_drawRate():UInt {
		return System.refreshRate;
	}
	
	static function set_defaultFont(value:Font):Font {
		if (value == null) return null;
		return defaultFont = value;
	}
	
}