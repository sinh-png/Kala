package kala.objects.shapes;

import kala.DrawingData;
import kala.math.color.Color;
import kala.math.Vec2;
import kha.Canvas;
import kha.FastFloat;
import kha.math.Vector2;

using kha.graphics2.GraphicsExtension;

class Polygon extends Shape {

	public var vertices(get, set):Array<Vec2>;
	var _vertices:Array<Vec2>;
	public var vector2Array(default, null):Array<Vector2>;
	
	public function new(vertices:Array<Vec2>, fill:Bool = true, outline:Bool = false) {
		super(fill, outline);
		this.vertices = vertices;
	}
	
	override public function destroy(destroyBehaviors:Bool = true):Void {
		super.destroy(destroyBehaviors);
		vector2Array = null;
		_vertices = null;
	}
	
	override public function draw(data:DrawingData, canvas:Canvas):Void {
		applyDrawingData(data, canvas);
		
		applyFillDrawingData();
		canvas.g2.fillPolygon(0, 0, vector2Array);
		
		applyLineDrawingData();
		canvas.g2.drawPolygon(0, 0, vector2Array, lineStrenght);
	}
	
	inline function get_vertices():Array<Vec2> {
		return _vertices;
	}
	
	function set_vertices(value:Array<Vec2>):Array<Vec2> {
		_vertices = value;
		vector2Array = Vec2.toVector2Array(vertices);
		
		var minX:FastFloat = 0;
		var maxX:FastFloat = 0;
		var minY:FastFloat = 0;
		var maxY:FastFloat = 0;
		
		for (v in _vertices) {
			if (v.x < minX) minX = v.x;
			else if (v.x > maxX) maxX = v.x;
			
			if (v.y < minY) minY = v.y;
			else if (v.y > maxY) maxY = v.y;
		}
		
		_width = Math.abs(maxX - minX);
		_height = Math.abs(maxY - minY);
		
		bufferOriginX = -minX;
		bufferOriginY = -minY;
		
		return value;
	}
	
}