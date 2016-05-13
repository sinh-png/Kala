package kala.objects.shapes;

import kala.DrawingData;
import kala.math.color.Color;
import kala.math.Vec2;
import kha.Canvas;
import kha.FastFloat;
import kha.graphics2.Graphics;
import kha.math.FastMatrix3;

using kha.graphics2.GraphicsExtension;

class Circle extends Shape {

	public var radius(default, set):FastFloat;
	public var segments(default, set):Int;
	
	private var _vertices:Array<Vec2> = new Array<Vec2>();
	
	public function new(radius:FastFloat, fill:Bool = true, outline:Bool = false) {
		super(fill, outline);
		this.radius = radius;
	}
	
	override public function reset(componentsReset:Bool = false):Void {
		super.reset(componentsReset);
		segments = 0;
	}
	
	override public function draw(data:DrawingData, canvas:Canvas):Void {
		applyDrawingData(data, canvas);

		applyFillDrawingData();
		drawFill(canvas.g2);
		
		applyLineDrawingData();
		drawOutline(canvas.g2);
	}
	
	function drawFill(g2:Graphics):Void {
		#if sys_html5
		if (kha.SystemImpl.gl == null) {
			var g:kha.js.CanvasGraphics = cast g2;
			g.fillCircle(0, 0, radius);
			return;
		}
		#end
		
		if (segments <= 0) {
			segments = Math.floor(10 * Math.sqrt(radius));
		}
			
		var p1:Vec2;
		var p2:Vec2;
		for (i in 0..._vertices.length - 1) {
			p1 = _vertices[i];
			p2 = _vertices[i + 1];
			g2.fillTriangle(p1.x, p1.y, p2.x, p2.y, 0, 0);
		}
		
		p1 = _vertices[_vertices.length - 1];
		p2 = _vertices[0];
		g2.fillTriangle(p1.x, p1.y, p2.x, p2.y, 0, 0);
	}
	
	function drawOutline(g2:Graphics):Void {
		#if sys_html5
		if (kha.SystemImpl.gl == null) {
			var g:kha.js.CanvasGraphics = cast g2;
			radius -= lineStrenght / 2; // Reduce radius to fit the line thickness within image width / height.
			g.drawCircle(0, 0, radius, lineStrenght);
			return;
		}
		#end
		
		var p1:Vec2;
		var p2:Vec2;
		for (i in 0..._vertices.length - 1) {
			p1 = _vertices[i];
			p2 = _vertices[i + 1];
			g2.drawLine(p1.x, p1.y, p2.x, p2.y, lineStrenght);
		}
		
		p1 = _vertices[_vertices.length - 1];
		p2 = _vertices[0];
		g2.drawLine(p1.x, p1.y, p2.x, p2.y, lineStrenght);
	}
	
	function updateVertices():Void {
		var segments = this.segments;
		if (segments <= 0) {
			segments = Math.floor(10 * Math.sqrt(radius));
		}
		
		if (_vertices.length > segments) _vertices.splice(0, _vertices.length - segments);
		
		var theta = 2 * Math.PI / segments;
		var c = Math.cos(theta);
		var s = Math.sin(theta);
		
		var x = radius;
		var y:FastFloat = 0;
		var t:FastFloat;
		
		var point:Vec2;
		
		for (i in 0...segments) {
			if (i < _vertices.length) {
				point = _vertices[i];
			} else {
				point = new Vec2();
				_vertices.push(point);
			}
			
			point.set(x, y);

			t = x;
			x = c * x - s * y;
			y = c * y + s * t;
		}
	}
	
	function set_radius(value:FastFloat):FastFloat {
		radius = value;
		updateVertices();
		bufferOriginX = bufferOriginY = radius;
		_width = _height = radius * 2;
		return value;
	}

	function set_segments(value:Int):Int {
		segments = value;
		updateVertices();
		return value;
	}
	
}