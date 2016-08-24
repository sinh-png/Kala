package kala.behaviors.display;

import kala.behaviors.Behavior;
import kala.DrawingData;
import kala.math.Matrix;
import kala.math.Rect.RectI;
import kala.objects.Object;
import kha.Canvas;

/**
 * Used to limit the rendering arena of an object.
 * 
 * Currently does not work correctly on HTML5 target when used on objects that are rendered on a View.
 */
class Clip extends Behavior<Object> {

	public var arena(default, null):RectI = new RectI();
	public var absolutePosition:Bool;
	public var enable:Bool;
	
	public function new(?object:Object, x:Int, y:Int, width:Int, height:Int) {
		super(object);
		arena.set(x, y, width, height);
	}
	
	override public function reset():Void {
		super.reset();
		arena.set();
		absolutePosition = false;
		enable = true;
	}
	
	override public function addTo(object:Object):Behavior<Object> {
		super.addTo(object);
		
		object.onPreDraw.notifyPrivateCB(this, preDrawHandle);
		object.onPostDraw.notifyPrivateCB(this, postDrawHandle);

		return this;
	}
	
	override public function remove():Void {
		if (object != null) {
			object.onPreDraw.removePrivateCB(this, preDrawHandle);
			object.onPostDraw.removePrivateCB(this, postDrawHandle);
		}
		
		super.remove();
	}
	
	function preDrawHandle(obj:Object, data:DrawingData, canvas:Canvas):Bool {
		if (enable) {
			if (data.extra == null || data.extra.clip == null) {
				if (absolutePosition) canvas.g2.scissor(arena.x, arena.y, arena.width, arena.height);
				else canvas.g2.scissor(arena.x + Std.int(object.x), arena.y + Std.int(object.y), arena.width, arena.height);
			} else {
				var absArena = (absolutePosition ?
					this.arena :
					new RectI(this.arena.x + Std.int(object.x), this.arena.y + Std.int(object.y), this.arena.width, this.arena.height)
				);
				
				var intersectedArena = absArena.getIntersection(data.extra.clip);
				
				if (intersectedArena == null) {
					canvas.g2.scissor(absArena.x, absArena.y, absArena.width, absArena.height);
					if (obj.isGroup) {
						if (data.extra == null) data.extra = { clip : absArena };
						else data.extra.clip = absArena;
					}
				} else {
					canvas.g2.scissor(intersectedArena.x, intersectedArena.y, intersectedArena.width, intersectedArena.height);
					if (obj.isGroup) {
						if (data.extra == null) data.extra = { clip : intersectedArena };
						else data.extra.clip = intersectedArena;
					}
				}
			}
		}
		
		return false;
	}
	
	function postDrawHandle(obj:Object, data:DrawingData, canvas:Canvas):Void {
		if (enable) {
			#if flash
			canvas.g2.scissor(0, 0, -1, -1);
			#else
			canvas.g2.disableScissor();
			#end
		}
	}
	
}