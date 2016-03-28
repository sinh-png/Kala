package kala.objects.shapes;

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
	
	override public function draw(
		?antialiasing:Bool = false, 
		?transformation:FastMatrix3, 
		?color:Color, ?colorBlendMode:ColorBlendMode, 
		?opacity:FastFloat = 1, 
		canvas:Canvas
	):Void {
		applyDrawingData(antialiasing, transformation, null, colorBlendMode, opacity, canvas);

		applyDrawingFillData();
		canvas.g2.fillPolygon(0, 0, [for (vector in vertices) vector]);
		
		applyDrawingLineData();
		canvas.g2.drawPolygon(0, 0, [for (vector in vertices) vector], lineStrenght);
	}
	
}