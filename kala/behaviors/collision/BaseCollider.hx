package kala.behaviors.collision;

import kala.debug.Debug;
import kala.DrawingData;
import kala.behaviors.Behavior;
import kala.behaviors.collision.shapes.CollisionShape;
import kala.math.color.Color;
import kala.math.Matrix;
import kala.math.Vec2;
import kala.objects.Object;
import kha.Canvas;
import kha.FastFloat;

#if (debug || kala_debug)
import kala.debug.Debug.DebugDrawCall;
#end

using kha.graphics2.GraphicsExtension;

interface ICollider extends IBehavior {
	
	public var shapes:Array<CollisionShape>;
	
	public function test(collider:ICollider):CollisionResult;
	public function testPoint(pointX:FastFloat, pointY:FastFloat):Bool;
	public function drawDebug(color:UInt, ?fill:Bool = false, ?lineStrenght:FastFloat = 1, canvas:Canvas):Void;
	
	private function postDrawUpdate(obj:Object, data:DrawingData, canvas:Canvas):Void;
	
}

@:access(kala.objects.Object)
@:allow(kala.behaviors.collision.shapes.CollisionShape)
class BaseCollider<T:Object> extends Behavior<T> implements ICollider {
	
	#if (debug || kala_debug)
	private static var _debugDrawCalls:Array<DebugDrawCall> = Debug.addDrawLayer();
	#end

	public var debugColor:Color = 0xffff0000;
	public var debugFill:Bool = false;
	public var debugLineStrenght:UInt = 2;
	
	public var shapes:Array<CollisionShape> = new Array<CollisionShape>();
	
	public var updated(default, null):Bool = false;
	
	override public function reset():Void {
		super.reset();
		while (shapes.length > 0) shapes.pop().put();
		updated = false;
	}
	
	override public function destroy():Void {
		super.destroy();
		while (shapes.length > 0) shapes.pop().put();
		shapes = null;
	}
	
	override public function addTo(object:T):BaseCollider<T> {
		super.addTo(object);
		object.onPostDraw.notifyPrivateCB(this, postDrawUpdate);
		return this;
	}
	
	override public function remove():Void {
		object.onPostDraw.removePrivateCB(this, postDrawUpdate);
		super.remove();
	}

	/**
	 * Collision test this collider with another collider.
	 * If you want to test when the object is invisible and postDrawUpdate is set to true, use forceTest instead.
	 * 
	 * @param	collider	The collider to be tested.
	 * @return				The result data. Return null if there was no collision.
	 */
	public function test(collider:ICollider):CollisionResult {
		if (!updated) return null;
		
		var result:CollisionResult;
		
		for (shapeA in shapes) {
			for (shapeB in collider.shapes) {
				result = shapeA.test(shapeB);
				if (result != null) return result;
			}
		}
		
		return null;
	}
	
	public function testPoint(pointX:FastFloat, pointY:FastFloat):Bool {
		if (!updated) return false;
		
		for (shape in shapes) {
			if (shape.testPoint(pointX, pointY)) return true;
		}
		
		return false;
	}
	
	public function drawDebug(color:UInt, ?fill:Bool = false, ?lineStrenght:FastFloat = 1, canvas:Canvas):Void {
		if (object == null) return;
		
		var g2 = canvas.g2;
		g2.color = color;
		g2.opacity = 1;
		
		for (shape in shapes) {
			g2.transformation = shape.matrix;
			
			if (fill) {
				g2.fillPolygon(
					0, 0,
					Vec2.toVector2Array(shape.getVertices())
				);
			} else {
				g2.drawPolygon(
					0, 0,
					Vec2.toVector2Array(shape.getVertices()), 
					lineStrenght
				);
			}
		}
	}
	
	function postDrawUpdate(obj:Object, data:DrawingData, canvas:Canvas):Void {
		updated = true;
		
		for (shape in shapes) shape.updateMatrix(obj._cachedDrawingMatrix);
		
		#if (debug || kala_debug)
		if (Debug.collisionDebug) {
			_debugDrawCalls.push(
				new DebugDrawCall(
					canvas,
					function(canvas) {
						drawDebug(debugColor, debugFill, debugLineStrenght, canvas);
					}
				)
			);
		}
		#end
	}
	
}