package kala;

import kala.Assets;
import kala.input.Keyboard;
import kala.input.Mouse;
import kala.math.color.Color;
import kala.objects.Object;
import kala.objects.group.Group;
import kha.FastFloat;
import kha.Font;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

@:access(kala.objects.Object)
@:access(kala.input.Keyboard)
@:access(kala.input.Mouse)
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
	 * If true, use frames as timing unit otherwise use milliseconds.
	 */
	public static var frameTiming:Bool = true;
	
	public static var width(default, null):Int = 0;
	public static var height(default, null):Int = 0;
	
	public static var screenWidth(default, null):Int = 0;
	public static var screenHeight(default, null):Int = 0;
	
	public static var antiAliasingSamples(default, null):UInt;
	
	public static var bgColor:Color = 0xff000000;
	
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
		?windowWidth:UInt = 800, ?windowHeight:UInt = 600,
		?antiAliasingSamples:UInt = 1,
		?updateRate:UInt = 60,
		?loadAllAssets:Bool = true
	):Void {
		Kala.antiAliasingSamples = antiAliasingSamples;
		
		width = windowWidth;
		height = windowHeight;
		
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
	
	static function startWorld(updateRate:UInt):Void {
		Keyboard.init();
		Mouse.init();

		System.notifyOnRender(renderWorld);
		Kala.updateRate = updateRate;
	}
	
	static function renderWorld(framebuffer:Framebuffer):Void {
		screenWidth = framebuffer.width;
		screenHeight = framebuffer.height;
		
		framebuffer.g2.begin(true, bgColor);
		
		world.callDraw(new DrawingData(), framebuffer);
		
		#if (debug || kala_debug)
		Debug.draw(framebuffer);
		#end
		
		framebuffer.g2.end();
	}
	
	static function updateWorld():Void {
		var time = Scheduler.time();
		var delta = time - _lastUpdateTime;
		_lastUpdateTime = time;
		
		fps = Math.round(1 / delta);
		
		//Keyboard.release();
		Mouse.release();
		
		//Keyboard.register();
		Mouse.register();
		
		delta = Std.int(delta * 1000);
		world.callUpdate(delta);
		Keyboard.update(delta);
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