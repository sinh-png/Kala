package kala.objects.shapes;

import kala.DrawingData;
import kala.math.Color;
import kala.objects.shapes.Shape.ShapeType;
import kha.Canvas;
import kha.FastFloat;
import kha.math.FastMatrix3;

using kha.graphics2.GraphicsExtension;

class Circle extends Shape {

	public var radius:FastFloat;
	public var segments:Int;
	
	public function new(radius:FastFloat, fill:Bool = true, outline:Bool = false) {
		super(fill, outline);
		type = ShapeType.CIRCLE;
		this.radius = radius;
	}
	
	override public function reset(componentsReset:Bool = false):Void {
		super.reset(componentsReset);
		segments = 0;
	}
	
	override public function draw(data:DrawingData, canvas:Canvas):Void {
		applyDrawingData(data, canvas);

		applyFillDrawingData();
		canvas.g2.fillCircle(0, 0, radius, segments);
		
		applyLineDrawingData();
		canvas.g2.drawCircle(0, 0, radius, lineStrenght, segments);
	}
	
}