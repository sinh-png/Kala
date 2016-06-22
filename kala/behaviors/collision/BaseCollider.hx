package kala.behaviors.collision;

import kala.behaviors.Behavior;
import kala.math.color.Color;
import kala.objects.Object;
import kha.Canvas;
import kha.FastFloat;

#if (debug || kala_debug)
import kala.debug.Debug;
#end

@:access(kala.objects.Object)
@:allow(kala.behaviors.collision.transformable.shapes.BaseCollisionShape)
class BaseCollider<T:Object> extends Behavior<T> {
	
	#if (debug || kala_debug)
	private static var _debugDrawCalls:Array<DebugDrawCall> = Debug.addDrawLayer();
	#end

	public var debugColor:Color = 0xffff0000;
	public var debugFill:Bool = false;
	public var debugLineStrenght:UInt = 2;
	
	public var shapes(default, null):Array<BaseCollisionShape> = new Array<BaseCollisionShape>();
	
	public var available(default, null):Bool = false;
	
	override public function reset():Void {
		super.reset();
		while (shapes.length > 0) shapes.pop().put();
		available = false;
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
		available = false;
		object.onPostDraw.removePrivateCB(this, postDrawUpdate);
		super.remove();
	}
	
	public function testPoint(pointX:FastFloat, pointY:FastFloat):Bool {
		if (!available) return false;
		
		for (shape in shapes) {
			if (shape.active && shape.testPoint(pointX, pointY)) return true;
		}
		
		return false;
	}
	
	public function drawDebug(color:UInt, ?fill:Bool = false, ?lineStrenght:FastFloat = 1, canvas:Canvas):Bool {
		if (object == null) return false;
		
		canvas.g2.color = color;
		canvas.g2.opacity = 1;
		
		return true;
	}
	
	function postDrawUpdate(obj:Object, data:DrawingData, canvas:Canvas):Void {
		available = true;
		
		for (shape in shapes) {
			if (!shape.active) continue;
			shape.update(obj._cachedDrawingMatrix);
		}
		
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