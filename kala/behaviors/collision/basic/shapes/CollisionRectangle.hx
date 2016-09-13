package kala.behaviors.collision.basic.shapes;

import kala.behaviors.collision.basic.shapes.ShapeType;
import kala.math.Collision;
import kala.util.pool.Pool;
import kha.Canvas;
import kha.FastFloat;

class CollisionRectangle extends CollisionShape {

	public static var pool(default, never) = new Pool<CollisionRectangle>(function() return new CollisionRectangle());
	
	public static inline function get():CollisionRectangle {
		var rect = pool.get();
		rect.reset();
		return rect;
	}
	
	//
	
	public var width:FastFloat;
	public var height:FastFloat;
	
	public function new() {
		super();
		type = ShapeType.RECTANGLE;
	}
	
	override public function testPoint(pointX:FastFloat, pointY:FastFloat):Bool {
		return Collision.pointVsRect(pointX, pointY, absX, absY, width, height);
	}
	
	override public function testCircle(circle:CollisionCircle):Bool {
		return Collision.fastCircleVsRect(
			circle.absX, circle.absY, circle.radius,
			absX, absY, width, height
		);
	}
	
	override public function testRect(rect:CollisionRectangle):Bool {
		return Collision.fastRectVsRect(
			absX, absY, width, height,
			rect.absX, rect.absY, rect.width, rect.height
		);
	}
	
	public inline function setSize(width:FastFloat, height:FastFloat):Void {
		this.width = width;
		this.height = height;
	}
	
	override public function drawDebug(?fill:Bool = false, ?lineStrenght:FastFloat = 1, canvas:Canvas):Void {
		super.drawDebug(fill, lineStrenght, canvas);
		if (fill) canvas.g2.fillRect(0, 0, width, height);
		else canvas.g2.drawRect(0, 0, width, height, lineStrenght);
	}
	
}