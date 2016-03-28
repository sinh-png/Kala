package kala.objects.shapes;

import kala.objects.Object;

class Shape extends Object {

	// To avoid using Std.is().
	public var type(default, null):ShapeType;
	
}

enum ShapeType {
	CIRCLE;
	RECTANGLE;
	POLYGON;
}