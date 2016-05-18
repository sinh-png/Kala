package kala;

#if (debug || kala_debug)
import kala.debug.Debugger;
import kha.Canvas;
import kha.Framebuffer;
#end

import kala.math.color.Color;

@:allow(kala.Kala)
class Debug {
	
	public static var collisionDebug:Bool = false;
	
	#if (debug || kala_debug)
	public static var debugger(default, never):Debugger = new Debugger();
	
	private static var _layers(default, null):Array<Array<DebugDrawCall>> = new Array<Array<DebugDrawCall>>();
	#end
	
	public static inline function log(value:Dynamic):Void {
		#if (debug || kala_debug)
		debugger.pushConsoleOutput(Std.string(value), Color.WHITE);
		#end
	}
	
	public static inline function echo(value:Dynamic):Void {
		#if (debug || kala_debug)
		debugger.pushConsoleOutput(Std.string(value), Color.WHITE);
		debugger.visible = true;
		#end
	}

	public static inline function error(message:String):Void {
		#if (debug || kala_debug)
		debugger.pushConsoleOutput("ERR: " + message, Color.RED);
		debugger.visible = true;
		#end
	}
	
	public static inline function print(value:Dynamic, ?textColor:Color = Color.WHITE, showDebugger:Bool = true):Void {
		#if (debug || kala_debug)
		debugger.pushConsoleOutput(Std.string(value), textColor);
		debugger.visible = showDebugger;
		#end
	}
	
	#if (debug || kala_debug)
	public static function addDrawLayer():Array<DebugDrawCall> {
		var layer = new Array<DebugDrawCall>();
		_layers.push(layer);
		return layer;
	}
	
	static inline function draw(framebuffer:Framebuffer):Void {
		var previewCanvas:Canvas = null;
		
		var hasDrawCall = false;
		
		for (layer in _layers) {
			for (call in layer.copy()) {
				hasDrawCall = true;
				
				layer.remove(call);
				
				if (previewCanvas != call.canvas) {
					if (previewCanvas != null) previewCanvas.g2.end();
					call.canvas.g2.begin(false);
				}
				
				call.exec();
				
				previewCanvas = call.canvas;
			}
		}
		
		if (previewCanvas != null && previewCanvas != framebuffer) {
			previewCanvas.g2.end();
			framebuffer.g2.begin(false);
		}
		
		if (debugger.visible) debugger.draw(framebuffer);
	}
	#end
	
}

#if (debug || kala_debug)
class DebugDrawCall {
	
	public var canvas:Canvas;
	public var callback:Canvas->Void;
	
	public inline function new(canvas:Canvas, callback:Canvas->Void) {
		this.canvas = canvas;
		this.callback = callback;
	}
	
	@:extern
	public inline function exec():Void {
		callback(canvas);
	}
	
}
#end
