package kala.objects.sprite;

import kala.DrawingData;
import kala.components.SpriteAnimation;
import kala.math.color.Color;
import kala.math.Rect;
import kha.Canvas;
import kha.FastFloat;
import kha.Image;
import kha.math.FastMatrix3;

class Sprite extends Object {

	public var image(default, null):Image;
	public var frameRect:RectI = new RectI();
	
	public var animation(default, null):SpriteAnimation;
	
	public function new(
		?image:Image, 
		?frameX:Int, ?frameY:Int, 
		?frameWidth:Int, ?frameHeight:Int,
		animated:Bool = false
	) {
		super();
		if (image != null) loadImage(image, frameX, frameY, frameWidth, frameHeight);
		
		if (animated) new SpriteAnimation(this);
	}

	override public function destroy(destroyComponents:Bool = true):Void {
		super.destroy(destroyComponents);
		image = null;
		frameRect = null;
		animation = null;
	}
	
	override public function draw(data:DrawingData, canvas:Canvas):Void {
		applyDrawingData(data, canvas);
		canvas.g2.drawSubImage(image, 0, 0, frameRect.x, frameRect.y, frameRect.width, frameRect.height);
	}
	
	override public function isVisible():Bool {
		return super.isVisible() && image != null && frameRect.width > 0 && frameRect.height > 0;
	}
	
	public function loadImage(
		image:Image, 
		?frameX:Int, ?frameY:Int, 
		?frameWidth:Int, ?frameHeight:Int
	):Sprite {
		this.image = image;
		
		if (frameX == null) frameX = 0;
		if (frameY == null) frameY = 0;
		if (frameWidth == null) frameWidth = image.width;
		if (frameHeight == null) frameHeight = image.height;
		
		frameRect.set(frameX, frameY, frameWidth, frameHeight);
		
		return this;
	}
	
	public function loadSpriteData(data:SpriteData, ?image:Image, ?animKey:String, ?animDelay:Int = -1):Sprite {
		if (image == null) image = data.image;
		
		if (data.frames.length == 1) {
			var frame = data.frames[0];
			return loadImage(image, frame.x, frame.y, frame.width, frame.height);
		}
		
		if (animation == null) new SpriteAnimation().addTo(this);

		if (animKey == null) animKey = data.key;
		
		animation.addAnimFromSpriteData(animKey, image, data, animDelay).play();
		
		return this;
	}
	
	override function get_width():FastFloat {
		return frameRect.width;
	}
	
	override function get_height():FastFloat {
		return frameRect.height;
	}
	
}

class SpriteData {
	
	public var key(default, null):String;
	public var image:Image;
	public var frames:Array<RectI>;
	public var animDelay:Int;
	//public var shapes;

	public inline function new(key:String, image:Image, frames:Array<RectI>, animDelay:UInt) {
		this.key = key;
		this.image = image;
		this.frames = frames;
		this.animDelay = animDelay;
	}
	
	@:extern
	public inline function clone():SpriteData {
		return new SpriteData(key, image, frames, animDelay);
	}
	
	@:extern
	public inline function setImage(image:Image):SpriteData {
		this.image = image;
		return this;
	}
	
	@:extern
	public inline function setFrames(frames:Array<RectI>):SpriteData {
		this.frames = frames;
		return this;
	}
	
	@:extern
	public inline function setAnimDelay(delay:Int):SpriteData {
		animDelay = delay;
		return this;
	}

}