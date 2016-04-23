package kala.components.input;

import kala.components.collision.Collider;
import kala.components.Component;
import kala.EventHandle.CallbackHandle;
import kala.input.Mouse;
import kala.objects.Object;
import kha.FastFloat;

class MouseInteraction extends Component<Object> {

	public var collider:Collider;
	
	public var onLeftClick:CallbackHandle<MouseInteraction->Void>;
	public var onRightClick:CallbackHandle<MouseInteraction->Void>;
	public var onOver:CallbackHandle<MouseInteraction->Void>;
	public var onOut:CallbackHandle<MouseInteraction->Void>;
	
	public var hovered(default, null):Bool;
	
	public function new() {
		super();
		
		onLeftClick = addCBHandle(new CallbackHandle<MouseInteraction->Void>());
		onRightClick = addCBHandle(new CallbackHandle<MouseInteraction->Void>());
		onOver = addCBHandle(new CallbackHandle<MouseInteraction->Void>());
		onOut = addCBHandle(new CallbackHandle<MouseInteraction->Void>());
	}
	
	override public function reset():Void {
		super.reset();
		hovered = false;
		
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
		collider = new Collider().addTo(object);
		object.onPostUpdate.notifyComponentCB(this, update);
		return this;
	}
	
	public inline function addObjectRect():MouseInteraction {
		collider.addObjectRect();
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
			
		} else if (hovered) {
			for (callback in onOver) {
				hovered = false;
				for (callback in onOut) callback.cbFunction(this);
			}
		}
	}
	
}