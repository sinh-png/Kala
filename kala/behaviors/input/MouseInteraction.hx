package kala.behaviors.input;

#if kala_mouse

import kala.behaviors.collision.transformable.Collider;
import kala.behaviors.collision.transformable.shapes.CollisionCircle;
import kala.behaviors.collision.transformable.shapes.CollisionPolygon;
import kala.behaviors.collision.transformable.shapes.CollisionShape;
import kala.behaviors.Behavior;
import kala.EventHandle.CallbackHandle;
import kala.math.color.Color;
import kala.math.Vec2;
import kala.input.Mouse;
import kala.objects.group.View;
import kala.objects.Object;
import kha.FastFloat;

class MouseInteraction extends Behavior<Object> {
	
	public var collider:Collider;
	public var debugColor:Color = 0xffff00ff;
	public var debugFill:Bool = false;
	public var debugLineStrenght:UInt = 2;
	
	public var hovered(default, null):Bool;
	
	public var left(default, null):MouseInteractionInput = new MouseInteractionInput(MouseButton.LEFT);
	public var right(default, null):MouseInteractionInput = new MouseInteractionInput(MouseButton.RIGHT);
	public var middle(default, null):MouseInteractionInput = new MouseInteractionInput(MouseButton.MIDDLE);
	
	public var onButtonInput(default, null):CallbackHandle<MouseInteraction->MouseInteractionInput->Void>;
	public var onWheel(default, null):CallbackHandle<MouseInteraction->Int->Void>;
	public var onOver(default, null):CallbackHandle<MouseInteraction->Void>;
	public var onOut(default, null):CallbackHandle<MouseInteraction->Void>;
	
	public var dragable:Bool;
	public var dragButtons:Array<MouseButton> = [MouseButton.LEFT];
	public var dragging:Bool;
	
	public var view:View;
	
	private var _dragPointX:FastFloat;
	private var _dragPointY:FastFloat;
	
	public function new(?object:Object, ?collider:Collider, objectRectScale:FastFloat = 0) {
		super();
		
		this.collider = collider == null ? new Collider() : collider;
		
		onButtonInput = addCBHandle(new CallbackHandle<MouseInteraction->MouseInteractionInput->Void>());
		onWheel = addCBHandle(new CallbackHandle<MouseInteraction->Int->Void>());
		onOver = addCBHandle(new CallbackHandle<MouseInteraction->Void>());
		onOut = addCBHandle(new CallbackHandle<MouseInteraction->Void>());
		
		if (object != null) {
			addTo(object);
			if (objectRectScale > 0) addObjectRectMask(objectRectScale);
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
		
		dragButtons = null;
		
		destroyCBHandles();
		onButtonInput = null;
		onWheel = null;
		onOver = null;
		onOut = null;
		
		view = null;
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
	
	public inline function addCircleMask(x:FastFloat, y:FastFloat, radius:FastFloat):CollisionCircle {
		return collider.addCircle(x, y, radius);
	}
	
	public inline function addRectMask(x:FastFloat, y:FastFloat, width:FastFloat, height:FastFloat):CollisionPolygon {
		return collider.addRect(x, y, width, height);
	}
	
	public inline function addPolygonMask(x:FastFloat, y:FastFloat, vertices:Array<Vec2>, concave:Bool = false):Array<CollisionPolygon> {
		return collider.addPolygon(x, y, vertices, concave);
	}
	
	public inline function addObjectRectMask():CollisionPolygon {
		return collider.addObjectRect();
	}
	
	public inline function addShapeMask(shape:CollisionShape):CollisionShape {
		return collider.addShape(shape);
	}
	
	function update(obj:Object, elapsed:FastFloat):Void {
		var m:Vec2;
		
		if (view == null) m = new Vec2(Mouse.x, Mouse.y);
		else m = view.project(Mouse.x, Mouse.y);
	
		if (collider.testPoint(m.x, m.y)) {
			if (!hovered) {
				hovered = true;
				for (callback in onOver) callback.cbFunction(this);
			}
			
			if (Mouse.LEFT.pressed) {
				if (left.duration == -1) {
					left.duration = 0;
					left.clicked = Mouse.LEFT.justPressed;
				} else {
					left.duration += elapsed;
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
					right.duration += elapsed;
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
					middle.duration += elapsed;
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
				_dragPointX = m.x - obj.x;
				_dragPointY = m.y - obj.y;
				dragging = true;
			}
		} else {
			if (hovered) {
				for (callback in onOver) {
					hovered = false;
					for (callback in onOut) callback.cbFunction(this);
				}
			}
			
			if (left.resetOnMovingOut) left.duration = -1;
			if (right.resetOnMovingOut) right.duration = -1;
			if (middle.resetOnMovingOut) middle.duration = -1;
			
			left.pressed = right.pressed = middle.pressed = false;
		}
		
		if (dragable && dragging && dragButtons != null &&  Mouse.checkAnyPressed(dragButtons)) {
			obj.x = m.x - _dragPointX;
			obj.y = m.y - _dragPointY;
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

@:allow(kala.behaviors.input.MouseInteraction)
class MouseInteractionInput {
	
	public var button(default, null):MouseButton;

	public var pressed(default, null):Bool;
	public var clicked(default, null):Bool;
	public var justReleased(default, null):Bool;
	
	/**
	 * The time the button has been pressed on the behavior.
	 */
	public var duration(default, null):FastFloat = -1;
	
	/**
	 * Whether to reset duration when cursor is moving out of the behavior or not.
	 */
	public var resetOnMovingOut:Bool = true;
	
	inline function new(button:MouseButton) {
		this.button = button;
	}
	
}

#end