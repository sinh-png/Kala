package kala.objects.shapes;

import kala.DrawingData;
import kha.Canvas;
import kha.FastFloat;
import kala.math.Color.ColorBlendMode;
import kala.math.Color;
import kha.math.FastMatrix3;

class Rectangle extends Shape {

	public function new(width:Int, height:Int, fill:Bool = true, outline:Bool = false) {
		super(fill, outline);
		_width = width;
		_height = height;
	}
	
	override public function draw(data:DrawingData, canvas:Canvas):Void {
		applyDrawingData(data, canvas);

		applyFillDrawingData();
		canvas.g2.fillRect(0, 0, _width, _height);

		applyLineDrawingData();
		canvas.g2.drawRect(0, 0, _width, _height, lineStrenght);
	}
	
}