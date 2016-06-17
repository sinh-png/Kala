package kala.behaviors.collision.basic.shapes;

import kala.behaviors.collision.basic.shapes.CollisionCircle;
import kala.behaviors.collision.basic.shapes.CollisionRectangle;
import kala.behaviors.collision.basic.shapes.ShapeType;
import kala.math.Collision;
import kala.util.pool.Pool;
import kha.Canvas;
import kha.FastFloat;

using kha.graphics2.GraphicsExtension;

class CollisionCircle extends CollisionShape {

	public static var pool(default, never) = new Pool<CollisionCircle>(function() return new CollisionCircle());
	
	public static inline function get():CollisionCircle {
		var circle = pool.get();
		circle.reset();
		return circle;
	}
	
	//
	
	public var radius:FastFloat;
	
	public function new() {
		super();
		type = ShapeType.CIRCLE;
	}
	
	override public function testCircle(circle:CollisionCircle):Bool {
		return Collision.fastCircleVsCircle(
			absX, absY, radius,
			circle.absX, circle.absY, circle.radius
		);
	}
	
	override public function testRect(rect:CollisionRectangle):Bool {
		return Collision.fastCircleVsRect(
			absX, absY, radius,
			rect.absX, rect.absY, rect.width, rect.height
		);
	}
	
	override public function drawDebug(?fill:Bool = false, ?lineStrenght:FastFloat = 1, canvas:Canvas):Void {
		super.drawDebug(fill, lineStrenght, canvas);
		if (fill) canvas.g2.fillCircle(0, 0, radius);
		else canvas.g2.drawCircle(0, 0, radius, lineStrenght);
	}
	
}