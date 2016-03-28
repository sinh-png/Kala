package kala.objects;

import kala.math.Color;
import kala.math.Rect;
import kha.Canvas;
import kha.FastFloat;
import kha.Image;
import kha.math.FastMatrix3;

class Sprite extends Object {

	public var image(default, null):Image;
	public var frameRect:RectI = new RectI();
	
	public function new(
		?image:Image, 
		?frameX:Int, ?frameY:Int, 
		?frameWidth:Int, ?frameHeight:Int
	) {
		super();
		if (image != null) loadImage(image, frameX, frameY, frameWidth, frameHeight);
	}

	override public function destroy(componentsDestroy:Bool = true):Void {
		super.destroy(componentsDestroy);
		image = null;
		frameRect = null;
	}
	
	override public function reset(componentsReset:Bool = true):Void {
		super.reset();
		image = null;
		frameRect.set();
	}
	
	override public function draw(
		?antialiasing:Bool = false,
		?transformation:FastMatrix3, 
		?color:Color, ?colorBlendMode:ColorBlendMode,
		?opacity:FastFloat = 1,
		canvas:Canvas
	):Void {
		applyDrawingData(antialiasing, transformation, color, colorBlendMode, opacity, canvas);
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
	
	override function get_width():FastFloat {
		return frameRect.width;
	}
	
	override function get_height():FastFloat {
		return frameRect.height;
	}
	
}


