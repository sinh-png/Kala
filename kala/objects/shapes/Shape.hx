package kala.objects.shapes;

import kala.math.Color;
import kala.objects.Object;

class Shape extends Object {

	// To avoid using Std.is().
	public var type(default, null):ShapeType;
	
	public var lineStrenght:UInt = 1;
	public var lineColor:Color = new Color();
	public var fillColor:Color = new Color();
	
	override public function destroy(componentsDestroy:Bool = true):Void {
		super.destroy(componentsDestroy);
		lineColor = fillColor = null;
	}
	
	override public function reset(componentsReset:Bool = true):Void {
		super.reset(componentsReset);
		lineStrenght = 1;
		lineColor.set();
		fillColor.set();
	}
	
	function getLineDrawingColor(overlayColor:Color):UInt {
		
	}
	
}

enum ShapeType {
	CIRCLE;
	RECTANGLE;
	POLYGON;
}