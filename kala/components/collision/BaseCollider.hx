package kala.components.collision;

import kala.DrawingData;
import kala.components.Component;
import kala.components.collision.CollisionShape;
import kala.math.Color;
import kala.math.Vec2;
import kala.objects.Object;
import kha.Canvas;
import kha.FastFloat;
import kha.math.FastMatrix3;

using kha.graphics2.GraphicsExtension;
using kala.math.helpers.FastMatrix3Helper;

interface ICollider extends IComponent {
	
	public var postDrawUpdate(default, set):Bool;
	
	private var _shapes:Array<CollisionShape>;
	private var _matrix:FastMatrix3;
	
	public function test(collider:ICollider):CollisionResult;
	private function update():Void;
	
}

@:access(kala.objects.Object)
@:allow(kala.components.collision.CollisionShape)
class BaseCollider<T:Object> extends Component<T> implements ICollider {

	/**
	 * If true, update transformation on object post draw using the object already calculated drawing matrix.
	 * If false, update transformation on every collision testing. Might be slower if testing is done often.
	 * 
	 * DEFAULT: true
	 */
	public var postDrawUpdate(default, set):Bool;
	
	private var _postDrawCBAdded:Bool = false;
	
	private var _shapes:Array<CollisionShape> = new Array<CollisionShape>();
	
	private var _matrix:FastMatrix3;
	
	var _shapeMatrix:FastMatrix3 = FastMatrix3.translation(0, 0);

	override public function reset():Void {
		super.reset();
		postDrawUpdate = true;
		while (_shapes.length > 0) _shapes.pop().destroy();
	}
	
	override public function destroy():Void {
		super.destroy();
		
		while (_shapes.length > 0) _shapes.pop();
		_shapes = null;
		
		_matrix = null;
	}
	
	override public function addTo(object:T):BaseCollider<T> {
		super.addTo(object);
		
		if (postDrawUpdate && !_postDrawCBAdded) {
			object.onPostDraw.addComponentCB(this, postDrawCB);
			_postDrawCBAdded = true;
		}
		
		update();
		
		return this;
	}
	
	override public function remove():Void {
		super.remove();
		
		if (postDrawUpdate && object != null) {
			object.onPostDraw.removeComponentCB(this, postDrawCB);
			_postDrawCBAdded = false;
		}
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
		
		for (shapeA in _shapes) {
			for (shapeB in collider._shapes) {
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
		for (shape in _shapes) {
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
	
	public function drawDebug(color:Color, ?lineStrenght:FastFloat = 1, canvas:Canvas):Void {
		if (object == null) return;
		
		if (!postDrawUpdate) update();
		
		var g2 = canvas.g2;
		g2.color = color.argb();
		g2.opacity = 1;
		
		for (shape in _shapes) {
			g2.transformation = shape.updateMatrix().matrix;
			g2.drawPolygon(
				0, 0,
				Vec2.toVector2Array(shape.getVertices()), 
				lineStrenght
			);
		}
	}
	
	function postDrawCB(obj:Object, data:DrawingData, canvas:Canvas):Void {
		_matrix = obj._drawingMatrixCache;
	}
	
	function update():Void {
		_matrix = object.getDrawingMatrix();
	}
	
	function set_postDrawUpdate(value:Bool):Bool {
		if (object == null) return postDrawUpdate = value;
		
		if (value) {
			object.onPostDraw.addComponentCB(this, postDrawCB);
			_postDrawCBAdded = true;
		} else {
			object.onPostDraw.removeComponentCB(this, postDrawCB);
			_postDrawCBAdded = false;
		}
		
		return postDrawUpdate = value;
	}
	
}