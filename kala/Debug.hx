package kala;

import kha.Canvas;

@:allow(kala.Kala)
class Debug {
	
	public static var collisionDebug:Bool = false;
	
	#if (debug || kala_debug)
	private static var _layers(default, null):Array<Array<DebugDrawCall>> = new Array<Array<DebugDrawCall>>();
	#end

	public static function error(message:String):Void {
		
	}
	
	#if (debug || kala_debug)
	public static function addDrawLayer():Array<DebugDrawCall> {
		var layer = new Array<DebugDrawCall>();
		_layers.push(layer);
		return layer;
	}
	
	static inline function draw():Bool {
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
		
		if (previewCanvas != null) previewCanvas.g2.end();
		
		return hasDrawCall;
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

class DebugConsole {
	
	public function new() {
		
	}
	
	public function draw():Void {
		
	}
	
	public function update():Void {
		
	}
	
}
#end