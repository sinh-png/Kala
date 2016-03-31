package kala.objects.shapes;

import kala.DrawingData;
import kala.math.Color;
import kala.math.Vec2;
import kha.Canvas;
import kha.FastFloat;
import kha.math.FastMatrix3;

using kha.graphics2.GraphicsExtension;

class Polygon extends Shape {

	public var vertices:Array<Vec2>;
	
	public function new(vertices:Array<Vec2>) {
		super();
		this.vertices = vertices;
	}
	
	override public function draw(data:DrawingData, canvas:Canvas):Void {
		applyDrawingData(data, canvas);
		
		applyDrawingFillData();
		canvas.g2.fillPolygon(0, 0, [for (vector in vertices) vector.toVector2()]);
		
		applyDrawingLineData();
		canvas.g2.drawPolygon(0, 0, [for (vector in vertices) vector.toVector2()], lineStrenght);
	}
	
	public function getTransformedVertices():Array<Vec2> {
		var verts = new Array<Vec2>();
		for (vert in vertices) {
			verts.push(vert.transform(getDrawingMatrix()));
		}
		return verts;
	}
	
}