package kala.objects.shapes;

import kala.math.Color;
import kha.Canvas;
import kha.FastFloat;
import kha.math.FastMatrix3;

using kha.graphics2.GraphicsExtension;

class Circle extends Shape {

	public var radius:FastFloat;
	public var segments:Int;
	
	public function new(radius:FastFloat) {
		super();
		type = ShapeType.CIRCLE;
		this.radius = radius;
	}
	
	override public function draw(
		?antialiasing:Bool = false, 
		?transformation:FastMatrix3, 
		?color:Color, ?colorBlendMode:ColorBlendMode, 
		?opacity:FastFloat = 1, 
		canvas:Canvas
	):Void {
		applyDrawingData(antialiasing, transformation, null, colorBlendMode, opacity, canvas);

		if (color == null) {
			color = this.color();
		} else {
			color = Color.fromARGB(0xffffffff)
				.blend(Color.blendColors(this.color, color, colorBlendMode), ColorBlendMode.OVERLAY);
		}
		
		var g2 = canvas.g2;
	}
	
}