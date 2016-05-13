package kala.components.input;
import kala.math.color.Color;

#if (debug || kala_debug || kala_mouse)

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
	public var debugColor:Color = 0xffff00ff;
	public var debugFill:Bool = false;
	public var debugLineStrenght:UInt = 2;
	
	public var hovered(default, null):Bool;
	
	public var left(default, null):MouseInteractionInput = new MouseInteractionInput(MouseButton.LEFT);
	public var right(default, null):MouseInteractionInput = new MouseInteractionInput(MouseButton.RIGHT);
	public var middle(default, null):MouseInteractionInput = new MouseInteractionInput(MouseButton.MIDDLE);
	
	public var onButtonInput:CallbackHandle<MouseInteraction->MouseInteractionInput->Void>;
	public var onWheel:CallbackHandle<MouseInteraction->Int->Void>;
	public var onRollOver:CallbackHandle<MouseInteraction->Void>;
	public var onRollOut:CallbackHandle<MouseInteraction->Void>;
	
	public var dragable:Bool;
	public var dragButtons:Array<MouseButton> = [MouseButton.LEFT];
	public var dragging:Bool;
	
	private var _dragPointX:FastFloat;
	private var _dragPointY:FastFloat;
	
	
	public function new(?object:Object, addObjectRect:Bool = false) {
		super();
		
		collider = new Collider();
		
		onButtonInput = addCBHandle(new CallbackHandle<MouseInteraction->MouseInteractionInput->Void>());
		onWheel = addCBHandle(new CallbackHandle<MouseInteraction->Int->Void>());
		onRollOver = addCBHandle(new CallbackHandle<MouseInteraction->Void>());
		onRollOut = addCBHandle(new CallbackHandle<MouseInteraction->Void>());
		
		if (object != null) {
			addTo(object);
			if (addObjectRect) this.addObjectRect();
		}
	}
	
	override public function reset():Void {
		super.reset();
		hovered = false;
		dragable = false;
		dragging = false;
		if (collider != null) collider.reset();
	}
	
	override public function destroy():Void {
		super.destroy();
		
		collider.destroy();
		collider = null;
		
		left = right = middle = null;
		
		destroyCBHandles();
		onButtonInput = null;
		onRollOver = null;
		onRollOut = null;
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
	
	function update(obj:Object, delta:Int):Void {
		var mx = Mouse.x;
		var my = Mouse.y;
	
		if (collider.testPoint(mx, my)) {
			var e = 1;
			if (Kala.deltaTiming) e = delta;
			
			if (!hovered) {
				hovered = true;
				for (callback in onRollOver) callback.cbFunction(this);
			}
			
			if (Mouse.LEFT.pressed) {
				if (left.duration == -1) {
					left.duration = 0;
					left.clicked = Mouse.LEFT.justPressed;
				} else {
					left.duration += e;
					left.clicked = false;
				}
				
				left.pressed = true;
				
				dispatchButtonInput(left);
				
			} else {
				if (left.duration > -1) {
					left.duration = -1;
					left.justReleased = true;
					dispatchButtonInput(left);
				} else {
					left.justReleased = false;
				}
				
				left.pressed = false;
			}
			
			if (Mouse.RIGHT.pressed) {
				if (right.duration == -1) {
					right.duration = 0;
					right.clicked = Mouse.RIGHT.justPressed;
				} else {
					right.duration += e;
					right.clicked = false;
				}
				
				right.pressed = true;
				
				dispatchButtonInput(right);
				
			} else {
				if (right.duration > -1) {
					right.duration = -1;
					right.justReleased = true;
					dispatchButtonInput(right);
				} else {
					right.justReleased = false;
				}
				
				right.pressed = false;
			}
			
			if (Mouse.MIDDLE.pressed) {
				if (middle.duration == -1) {
					middle.duration = 0;
					middle.clicked = Mouse.MIDDLE.justPressed;
				} else {
					middle.duration += e;
					middle.clicked = false;
				}
				
				middle.pressed = true;
				
				dispatchButtonInput(middle);
				
			} else {
				if (middle.duration > -1) {
					middle.duration = -1;
					middle.justReleased = true;
					dispatchButtonInput(middle);
				} else {
					middle.justReleased = false;
				}
				
				middle.pressed = false;
			}
			
			if (Mouse.wheel != 0) {
				for (callback in onWheel) callback.cbFunction(this, Mouse.wheel);
			}
			
			if (dragButtons != null && Mouse.checkAnyJustPressed(dragButtons)) {
				_dragPointX = mx - obj.x;
				_dragPointY = my - obj.y;
				dragging = true;
			}
		} else {
			if (hovered) {
				for (callback in onRollOver) {
					hovered = false;
					for (callback in onRollOut) callback.cbFunction(this);
				}
			}
			
			if (left.resetOnMovingOut) left.duration = -1;
			if (right.resetOnMovingOut) right.duration = -1;
			if (middle.resetOnMovingOut) middle.duration = -1;
			
			left.pressed = right.pressed = middle.pressed = false;
		}
		
		if (dragable && dragging && dragButtons != null &&  Mouse.checkAnyPressed(dragButtons)) {
			obj.x = mx - _dragPointX;
			obj.y = my - _dragPointY;
		} else {
			dragging = false;
		}
		
		#if (debug || kala_debug)
		if (collider != null) {
			collider.debugColor = debugColor;
			collider.debugFill = debugFill;
			collider.debugLineStrenght = debugLineStrenght;
		}
		#end
	}
	
	inline function dispatchButtonInput(input:MouseInteractionInput):Void {
		for (callback in onButtonInput) callback.cbFunction(this, input);
	}
	
}

@:allow(kala.components.input.MouseInteraction)
class MouseInteractionInput {
	
	public var button(default, null):MouseButton;

	public var pressed(default, null):Bool;
	public var clicked(default, null):Bool;
	public var justReleased(default, null):Bool;
	
	/**
	 * The time the button has been pressed on the component.
	 */
	public var duration(default, null):Int = -1;
	
	/**
	 * Whether to reset duration when cursor is moving out of the component or not.
	 */
	public var resetOnMovingOut:Bool = true;
	
	inline function new(button:MouseButton) {
		this.button = button;
	}
	
}

#end