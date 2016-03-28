package kala.objects.shapes;
import kha.Canvas;
import kha.FastFloat;
import kala.math.Color.ColorBlendMode;
import kala.math.Color;
import kha.math.FastMatrix3;

class Rectangle extends Shape {

	public function new(width:Int, height:Int) {
		super();
		_width = width;
		_height = height;
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
		canvas.g2.fillRect(0, 0, _width, _height);

		applyDrawingLineData();
		canvas.g2.drawRect(0, 0, _width, _height, lineStrenght);
	}
	
}