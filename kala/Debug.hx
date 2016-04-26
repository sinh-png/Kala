package kala;

import kala.input.Keyboard;
import kala.input.Mouse;
import kala.math.Rect;
import kha.Canvas;
import kha.FastFloat;
import kha.Framebuffer;
import kha.graphics2.Graphics;
import kha.math.FastMatrix3;
import kha.Scheduler;

@:allow(kala.Kala)
class Debug {
	
	public static var collisionDebug:Bool = false;
	
	#if (debug || kala_debug)
	public static var console(default, never):DebugConsole = new DebugConsole();
	
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
		
		if (console.enable) console.draw(framebuffer);
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

@:access(kala.CallbackHandle)
class DebugConsole {
	
	public static inline var NORMAL = 0;
	public static inline var MAXIMIZED = 1;
	public static inline var MINIMIZED = 2;
	
	public var enable(default, set):Bool = false;
	
	public var rect(default, null):Rect = new Rect(0, 0, 600, 400);
	
	public var tab:DebugConsoleTab = CONSOLE;
	
	public var state:Int = NORMAL; // 0 - Normal, 1 - Maximized, 2 - Minimized.
	
	private var _dragging:Bool = false;
	private var _dragPointX:FastFloat;
	private var _dragPointY:FastFloat;
	
	private var _resizing:Bool = false;
	private var _resizePointX:FastFloat;
	private var _resizePointY:FastFloat;
	
	private var _maxRect:Rect = new Rect();
	private var _minRect:Rect = new Rect();
	
	private var _command:String = "";
	private var _cmdCursorVisible:Bool = true;
	private var _cmdCursorTimeTask:Int;
	
	private var _backspacePressingTime:Int = 0;
	
	public function new() {
		Keyboard.onKeyDown.notifyPrivateCB(this, function(key:Key) {
			switch(key) {
				case CHAR(c): 
					if (c == '`') {
						if (!enable) enable = true;
						else {
							
						}
					}
				default:
			}
		});
	}
	
	public function draw(canvas:Canvas):Void {
		var rect = this.rect;
		
		if (state == MAXIMIZED) { 
			_maxRect.set(0, 0, canvas.width, canvas.height);
			rect = _maxRect;
		} else if (state == MINIMIZED) {
			_minRect.set(rect.x, rect.y, rect.width, 24);
			rect = _minRect;
		} else {
			if (rect.width < 300) rect.width = 300;
			if (rect.height < 200) rect.height = 200;
		}
		
		if (rect.x < 0) rect.x = 0;
		else if (rect.x > canvas.width - rect.width) rect.x = canvas.width - rect.width;
		
		if (rect.y < 0) rect.y = 0;
		else if (rect.y > canvas.height - rect.height) rect.y = canvas.height - rect.height;
		
		var g = canvas.g2;
		g.transformation = FastMatrix3.translation(rect.x, rect.y);
		g.opacity = 1;
		
		// Background
		g.color = 0x88222222;
		g.fillRect(0, 0, rect.width , state == MINIMIZED ? 24 : rect.height);
		
		// Title bar background
		g.color = 0x44666666;
		g.fillRect(0, 0, rect.width , 24);
		
		var mx = Mouse.x;
		var my = Mouse.y;
		var ma = new Rect(rect.x, rect.y, rect.width, 24);
		
		// Dragging
		
		if (!_dragging && Mouse.didLeftClickOnRect(ma)) {
			_dragging = true;
			_dragPointX = mx - ma.x;
			_dragPointY = my - ma.y;
		}
		
		if (_dragging && Mouse.pressed.LEFT) {
			this.rect.x = mx - _dragPointX;
			this.rect.y = my - _dragPointY;
		} else {
			_dragging = false;
		}
		
		// Tab

		g.color = 0xffffffff;
		g.font = Kala.defaultFont;
		g.fontSize = 18;
		
		var s = '  -  FPS: ${Kala.fps}';
		
		switch(tab) {
			case CONSOLE:
				s = "CONSOLE" + s;
				if (state != MINIMIZED) drawConsole(rect, g);
				
			case DRAWING_SETTINGS:
				s = "DRAWING SETTINGS" + s;
				
			case MONITOR:
				s = "MONITOR" + s;
				
			case PROFILER:
				s = "PROFILER" + s;
		}
		
		g.drawString(s, 10, (24 - g.font.height(g.fontSize)) / 2);
		
		// Close button
		
		ma.set(rect.x + rect.width - 30, rect.y, 30, 24);
		if (Mouse.isHoveringRect(ma)) {
			g.color = 0x66999999;
			g.fillRect(rect.width - 30, 0, 30, 24);
			g.color = 0xffffffff;
			
			if (Mouse.justPressed.LEFT) enable = false;
		}
		
		g.drawLine(rect.width - 20, 7, rect.width - 10, 17, 1);
		g.drawLine(rect.width - 20, 17, rect.width - 10, 7, 1);
		
		// Restore / Maximize button
		
		ma.x -= 30;
		if (Mouse.isHoveringRect(ma)) {
			g.color = 0x66999999;
			g.fillRect(ma.x - rect.x, 0, 30, 24);
			g.color = 0xffffffff;
			
			if (Mouse.justPressed.LEFT) {
				if (state == MAXIMIZED) state = NORMAL;
				else state = MAXIMIZED;
			}
		}
		
		if (state == MAXIMIZED) {
			// Restore button
			g.drawLine(rect.width - 48, 9, rect.width - 47, 7, 1);
			g.drawLine(rect.width - 48, 7, rect.width - 40, 7, 1);
			g.drawLine(rect.width - 40, 7, rect.width - 40, 15, 1);
			g.drawLine(rect.width - 40, 15, rect.width - 42, 15, 1);
			g.drawRect(rect.width - 50, 9, 8, 8, 1);
		} else {
			// Maximize button
			g.drawRect(rect.width - 50, 7, 10, 10, 1);
		}
		
		// Minimize button
		
		if (Keyboard.justPressed.TAB) {
			if (state == MINIMIZED) state = NORMAL;
			else state = MINIMIZED;
		}
		
		ma.x -= 30;
		if (Mouse.isHoveringRect(ma)) {
			g.color = 0x66999999;
			g.fillRect(ma.x - rect.x, 0, 30, 24);
			g.color = 0xffffffff;
			
			if (Mouse.justPressed.LEFT) {
				if (state == MINIMIZED) state = NORMAL;
				else state = MINIMIZED;
			}
		}
		
		g.drawLine(rect.width - 80, 12, rect.width - 70, 12, 1);
		
		// Resize button
		
		if (state == NORMAL) {
			g.drawLine(rect.width - 9, rect.height, rect.width, rect.height - 9, 1);
			g.drawLine(rect.width - 6, rect.height, rect.width, rect.height - 6, 1);
			g.drawLine(rect.width - 3, rect.height, rect.width, rect.height - 3, 1);
			
			ma.set(rect.x + rect.width - 9, rect.y + rect.height - 9, 9, 9);
			if (!_resizing && Mouse.didLeftClickOnRect(ma)) {
				_resizing = true;
				_resizePointX = rect.width - mx + rect.x;
				_resizePointY = rect.height - my + rect.y;
			}
			
			if (_resizing && Mouse.pressed.LEFT) {
				rect.width = mx - rect.x + _resizePointX;
				rect.height = my - rect.y + _resizePointY;
			} else {
				_resizing = false;
			}
		}

	}
	
	function drawCMDField(rect:Rect, g:Graphics):Void {
		g.color = 0x44666666;
		g.fillRect(0, rect.height - 24, rect.width , 24);
		
		g.color = 0xffffffff;
		var s = _command;
		var i = 0;
		while (g.font.width(g.fontSize, s) > rect.width) s = s.substr(++i);
		g.drawString(s, 5, rect.height - 24 + (24 - g.font.height(g.fontSize)) / 2);
		
		if (_cmdCursorVisible) {
			g.fillRect(5 + g.font.width(g.fontSize, s), rect.height - 20, 2, 16);
		}
		
		if (Keyboard.pressed.BACKSPACE) {
			_backspacePressingTime++;
			if (_backspacePressingTime > 10 && _command.length > 0) {
				_command = _command.substr(0, _command.length - 1);
			}
		} else {
			_backspacePressingTime = 0;
		}
	}
	
	function onCMDIyping(key:Key):Void {
		if (state == MINIMIZED) return;
		
		switch(key) {
			case CHAR(c):
				if (c == '`') return;
				_command += c;
			
			case BACKSPACE:
				if (_backspacePressingTime < 10 && _command.length > 0) {
					_command = _command.substr(0, _command.length - 1);
				}
				
			case ENTER:
				execCMD(_command);
				_command = "";
				
			default:
		}
	}
	
	function execCMD(command:String):Void {
		if (command.length < 1) return;
	}
	
	function drawConsole(rect:Rect, g:Graphics):Void {
		drawCMDField(rect, g);
	}
	
	function set_enable(value:Bool):Bool {
		if (value) {
			if (!enable) {
				_cmdCursorTimeTask = Scheduler.addTimeTask(function() {
					_cmdCursorVisible = !_cmdCursorVisible;
				}, 0, 0.5);
				
				Keyboard.onKeyDown.notifyPrivateCB(this, onCMDIyping);
			}
		} else {
			if (enable) {
				Scheduler.removeTimeTask(_cmdCursorTimeTask);
				Keyboard.onKeyDown.remove(onCMDIyping);
			}
		}
		
		return enable = value;
	}
	
}

enum DebugConsoleTab {
	
	CONSOLE;
	DRAWING_SETTINGS;
	MONITOR;
	PROFILER;
	
}
#end