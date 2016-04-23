package kala.objects.shapes;

import kala.DrawingData;
import kala.math.color.Color;
import kala.math.Vec2;
import kha.Canvas;
import kha.FastFloat;
import kha.math.FastMatrix3;
import kha.math.Vector2;

using kha.graphics2.GraphicsExtension;

class Polygon extends Shape {

	public var vertices(default, set):Array<Vec2>;
	public var vector2Array(default, null):Array<Vector2>;
	
	public function new(vertices:Array<Vec2>, fill:Bool = true, outline:Bool = false) {
		super(fill, outline);
		this.vertices = vertices;
	}
	
	override public function draw(data:DrawingData, canvas:Canvas):Void {
		applyDrawingData(data, canvas);
		
		applyFillDrawingData();
		canvas.g2.fillPolygon(0, 0, vector2Array);
		
		applyLineDrawingData();
		canvas.g2.drawPolygon(0, 0, vector2Array, lineStrenght);
	}
	
	public function getTransformedVertices():Array<Vec2> {
		var verts = new Array<Vec2>();
		for (vert in vertices) {
			verts.push(vert.transform(getDrawingMatrix()));
		}
		return verts;
	}
	
	function set_vertices(value:Array<Vec2>):Array<Vec2> {
		vertices = value;
		vector2Array = Vec2.toVector2Array(vertices);
		
		var minX:FastFloat = 0;
		var maxX:FastFloat = 0;
		var minY:FastFloat = 0;
		var maxY:FastFloat = 0;
		
		for (v in vertices) {
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