package kala.behaviors.collision;

import kala.debug.Debug;
import kala.DrawingData;
import kala.behaviors.Behavior;
import kala.behaviors.collision.CollisionShape;
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
	
	public var postDrawUpdate(default, set):Bool;
	public var shapes:Array<CollisionShape>;
	public function test(collider:ICollider):CollisionResult;
	
	private var _matrix:Matrix;
	private function update():Void;
	
}

@:access(kala.objects.Object)
@:allow(kala.behaviors.collision.CollisionShape)
class BaseCollider<T:Object> extends Behavior<T> implements ICollider {
	
	#if (debug || kala_debug)
	private static var _debugDrawCalls:Array<DebugDrawCall> = Debug.addDrawLayer();
	#end

	public var debugColor:Color = 0xffff0000;
	public var debugFill:Bool = false;
	public var debugLineStrenght:UInt = 2;
	
	/**
	 * If true, update transformation on object post draw using the object already calculated drawing matrix.
	 * If false, update transformation on every collision testing. Might be slower if testing is done often.
	 * 
	 * DEFAULT: true
	 */
	public var postDrawUpdate(default, set):Bool;
	
	public var shapes:Array<CollisionShape> = new Array<CollisionShape>();
	
	private var _postDrawCBAdded:Bool = false;
	
	private var _matrix:Matrix;
	
	var _shapeMatrix:Matrix = Matrix.translation(0, 0);
	
	override public function reset():Void {
		super.reset();
		postDrawUpdate = true;
		while (shapes.length > 0) shapes.pop().put();
	}
	
	override public function destroy():Void {
		super.destroy();
		
		while (shapes.length > 0) shapes.pop().put();
		shapes = null;
		
		_matrix = null;
	}
	
	override public function addTo(object:T):BaseCollider<T> {
		super.addTo(object);
		
		if (postDrawUpdate && !_postDrawCBAdded) {
			object.onPostDraw.notifyPrivateCB(this, postDrawCB);
			_postDrawCBAdded = true;
		}
		
		update();
		
		return this;
	}
	
	override public function remove():Void {
		if (postDrawUpdate && object != null) {
			object.onPostDraw.removePrivateCB(this, postDrawCB);
			_postDrawCBAdded = false;
		}
		
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
		if (!postDrawUpdate) update();
		if (!collider.postDrawUpdate) collider.update();

		var result:CollisionResult;
		
		for (shapeA in shapes) {
			for (shapeB in collider.shapes) {
				result = shapeA.test(shapeB);
				if (result != null) return result;
			}
		}
		
		return null;
	}
	
	/**
	 * Force this collider to update then test it with another collider.
	 * 
	 * @param	collider	The collider to be tested.
	 * @return				The result data. Return null if there was no collision.
	 */
	public inline function forceTest(collider:ICollider):CollisionResult {
		var t = postDrawUpdate;
		postDrawUpdate = false;
		
		var result = test(collider);
		
		postDrawUpdate = t;
		
		return result;
	}	
	
	public function testPoint(pointX:FastFloat, pointY:FastFloat):Bool {
		for (shape in shapes) {
			if (shape.testPoint(pointX, pointY)) return true;
		}
		
		return false;
	}
	
	public function forceTestPoint(pointX:FastFloat, pointY:FastFloat):Bool {
		var t = postDrawUpdate;
		postDrawUpdate = false;
		
		var result = testPoint(pointX, pointY);
		
		postDrawUpdate = t;
		
		return result;
	}
	
	public function drawDebug(color:UInt, ?fill:Bool = false, ?lineStrenght:FastFloat = 1, canvas:Canvas):Void {
		if (object == null) return;
		
		if (!postDrawUpdate) update();
		
		var g2 = canvas.g2;
		g2.color = color;
		g2.opacity = 1;
		
		for (shape in shapes) {
			shape.updateMatrix();
			
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
	
	function postDrawCB(obj:Object, data:DrawingData, canvas:Canvas):Void {
		_matrix = obj._cachedDrawingMatrix;
		
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
	
	function update():Void {
		_matrix = object.getDrawingMatrix();
	}
	
	function set_postDrawUpdate(value:Bool):Bool {
		if (object == null) return postDrawUpdate = value;
		
		if (value) {
			object.onPostDraw.notifyPrivateCB(this, postDrawCB);
			_postDrawCBAdded = true;
		} else {
			object.onPostDraw.removePrivateCB(this, postDrawCB);
			_postDrawCBAdded = false;
		}
		
		return postDrawUpdate = value;
	}
	
}