package kala.objects.group;

import kala.DrawingData;
import kala.math.Vec2;
import kala.objects.Object;
import kala.math.Color;
import kala.math.Rect;
import kha.Canvas;
import kha.DepthStencilFormat;
import kha.FastFloat;
import kha.Image;
import kha.math.FastMatrix3;

@:access(kala.objects.group.Group)
class View extends Object {

	public var buffer(default, null):Image;
	
	public var viewPos:Vec2;
	
	public var viewWidth(default, null):UInt;
	public var viewHeight(default, null):UInt;
	
	/**
	 * Background color in RGB fortmat.
	 */
	public var bgColor:UInt;
	
	/**
	 * If true, will be fully transparent.
	 */
	public var transparent:Bool;
	
	public function new(
		viewX:FastFloat, viewY:FastFloat, viewWidth:UInt, viewHeight:UInt,
		?antiAliasingSamples:UInt
	) {
		super();
		if (antiAliasingSamples == null) antiAliasingSamples = Kala.antiAliasingSamples;
		buffer = Image.createRenderTarget(
			Std.int(viewWidth), Std.int(viewHeight), null, 
			DepthStencilFormat.NoDepthAndStencil, antiAliasingSamples
		);
		
		viewPos = new Vec2(viewX, viewY);
		this.viewWidth = viewWidth;
		this.viewHeight = viewHeight;
	}
	
	override public function reset(componentsReset:Bool = false):Void {
		super.reset(componentsReset);
		bgColor = 0;
		transparent = true;
	}
	
	override public function destroy(componentsDestroy:Bool = true):Void {
		super.destroy(componentsDestroy);
		
		buffer.unload();
		buffer = null;
		
		viewPos = null;
	}
	
	override public function draw(data:DrawingData, canvas:Canvas):Void {
		applyDrawingData(data, canvas);
		canvas.g2.drawImage(buffer, 0, 0);
	}
	
}