package kala.components.input;

import kala.components.collision.Collider;
import kala.components.collision.CollisionShape;
import kala.components.Component;
import kala.EventHandle.CallbackHandle;
import kala.input.Mouse;
import kala.math.Vec2;
import kala.objects.Object;
import kha.FastFloat;

class MouseInteraction extends Component<Object> {

	public var collider:Collider;
	
	public var dragable:Bool;
	public var dragButtons:Array<MouseButton> = [MouseButton.LEFT];
	
	public var onLeftClick:CallbackHandle<MouseInteraction->Void>;
	public var onRightClick:CallbackHandle<MouseInteraction->Void>;
	public var onOver:CallbackHandle<MouseInteraction->Void>;
	public var onOut:CallbackHandle<MouseInteraction->Void>;
	
	public var hovered(default, null):Bool;
	
	private var _dragPointX:FastFloat;
	private var _dragPointY:FastFloat;
	private var _dragging:Bool;
	
	public function new() {
		super();
		
		collider = new Collider();
		
		onLeftClick = addCBHandle(new CallbackHandle<MouseInteraction->Void>());
		onRightClick = addCBHandle(new CallbackHandle<MouseInteraction->Void>());
		onOver = addCBHandle(new CallbackHandle<MouseInteraction->Void>());
		onOut = addCBHandle(new CallbackHandle<MouseInteraction->Void>());
	}
	
	override public function reset():Void {
		super.reset();
		hovered = false;
		dragable = false;
		_dragging = false;
		if (collider != null) collider.reset();
	}
	
	override public function destroy():Void {
		super.destroy();
		
		collider.destroy();
		collider = null;
		
		destroyCBHandles();
		onLeftClick = null;
		onOver = null;
		onOut = null;
	}
	
	override public function addTo(object:Object):MouseInteraction {
		super.addTo(object);
		collider.addTo(object);
		object.onPostUpdate.notifyPrivateCB(this, update);
		return this;
	}
	
	override public function remove():Void {
		if (object != null) {
			collider.remove();
			object.onPostUpdate.removePrivateCB(this, update);
		}
		
		super.remove();
	}
	
	public inline function addCircle(x:FastFloat, y:FastFloat, radius:FastFloat):MouseInteraction {
		collider.addCircle(x, y, radius);
		return this;
	}
	
	public inline function addRect(x:FastFloat, y:FastFloat, width:FastFloat, height:FastFloat):MouseInteraction {
		collider.addRect(x, y, width, height);
		return this;
	}
	
	public inline function addPolygon(x:FastFloat, y:FastFloat, vertices:Array<Vec2>, concave:Bool = false):MouseInteraction {
		collider.addPolygon(x, y, vertices, concave);
		return this;
	}
	
	public inline function addObjectRect():MouseInteraction {
		collider.addObjectRect();
		return this;
	}
	
	public inline function addShape(shape:CollisionShape):MouseInteraction {
		collider.addShape(shape);
		return this;
	}
	
	function update(obj:Object, delta:FastFloat):Void {
		var mx = Mouse.x;
		var my = Mouse.y;
	
		if (collider.testPoint(mx, my)) {
			if (!hovered) {
				hovered = true;
				for (callback in onOver) callback.cbFunction(this);
			}
			
			if (Mouse.justPressed.LEFT) {
				for (callback in onLeftClick) callback.cbFunction(this);
			}
			
			if (Mouse.justPressed.RIGHT) {
				for (callback in onRightClick) callback.cbFunction(this);
			}
			
			if (dragButtons != null && Mouse.justPressed.checkButtons(dragButtons)) {
				_dragPointX = mx - obj.x;
				_dragPointY = my - obj.y;
				_dragging = true;
			}
		} else if (hovered) {
			for (callback in onOver) {
				hovered = false;
				for (callback in onOut) callback.cbFunction(this);
			}
		}
		
		if (dragable && _dragging && dragButtons != null &&  Mouse.pressed.checkButtons(dragButtons)) {
			obj.x = mx - _dragPointX;
			obj.y = my - _dragPointY;
		} else {
			_dragging = false;
		}
	}
	
}