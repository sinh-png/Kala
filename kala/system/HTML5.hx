package kala.system;

#if js
import js.Browser;
import js.html.CanvasElement;
import js.html.Node;
import kha.SystemImpl;

class HTML5 {

	public var mobile(get, never):Bool;
	public var canvas(default, null):CanvasElement;

	public function new() { 
		canvas = cast Browser.document.getElementById('khanvas');
	}
	
	public function fillPage():Void {
		var node = Browser.document.createElement('meta');
		node.setAttribute('name', "viewport");
		node.setAttribute('content', "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no");
		Browser.document.head.appendChild(node);
		
		var window = Browser.window;
	
		function resizeCanvas() {
			canvas.style.width = window.innerWidth;
			window.setTimeout(function() {
				canvas.style.height = window.innerHeight;
			}, 0);
		}
			
		window.addEventListener('resize', resizeCanvas, false);
		window.addEventListener('orientationchange', resizeCanvas, false);
		
		Browser.document.body.style.margin = '0';
		Browser.document.body.style.overflow = 'hidden';
		
		canvas.style.position = 'absolute';
		canvas.style.left = canvas.style.top = '0';
		canvas.style.width = canvas.style.height = '100%';
	}
	
	inline function get_mobile():Bool {
		return SystemImpl.mobile;
	}
	
}
#end