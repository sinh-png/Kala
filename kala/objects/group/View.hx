package kala.objects.group;

import kala.DrawingData;
import kala.math.Vec2;
import kala.math.Vec2T;
import kala.objects.Object;
import kala.math.color.Color;
import kala.math.Rect;
import kha.Canvas;
import kha.FastFloat;
import kha.graphics2.ImageScaleQuality;
import kha.Image;
import kha.graphics4.DepthStencilFormat;

@:access(kala.objects.group.Group)
class View extends Object {

	public var viewBuffer(default, null):Image;
	
	public var viewport(default, null):Rect;
	
	public var halign:Null<FastFloat>;
	public var valign:Null<FastFloat>;
	
	public var scaleMode:ScaleMode;
	
	/**
	 * Background color in RGB fortmat.
	 */
	public var bgColor:UInt;
	
	/**
	 * If true, will be fully transparent.
	 */
	public var transparent:Bool;
	
	public function new(
		viewX:FastFloat, viewY:FastFloat,
		viewWidth:UInt, viewHeight:UInt,
		?antiAliasingSamples:UInt = 1
	) {
		super();
		viewBuffer = Image.createRenderTarget(
			Std.int(viewWidth), Std.int(viewHeight), null, 
			DepthStencilFormat.NoDepthAndStencil, antiAliasingSamples
		);
		
		viewBuffer.g2.imageScaleQuality = ImageScaleQuality.Low;
		
		
		viewport = new Rect(viewX, viewY, viewWidth, viewHeight);
	}
	
	override public function reset(resetBehaviors:Bool = false):Void {
		super.reset(resetBehaviors);
		bgColor = 0;
		transparent = true;
		scaleMode = NONE;
	}
	
	override public function destroy(destroyBehaviors:Bool = true):Void {
		super.destroy(destroyBehaviors);
		
		viewBuffer.unload();
		viewBuffer = null;
		
		viewport = null;
	}
	
	override public function draw(data:DrawingData, canvas:Canvas):Void {
		var cw = canvas.width;
		var ch = canvas.height;
		
		var w:FastFloat = viewport.width = viewBuffer.width;
		var h:FastFloat = viewport.height = viewBuffer.height;
		
		switch(scaleMode) {
			
			case EXACT:
				scale.setXY(cw / w, ch / h);
				w = cw;
				h = ch;
			
			case RATIO:
				var hs = cw / w;
				var vs = ch / h;
				
				var s = Math.min(hs, vs);
				scale.setXY(s, s);
				
				w *= s;
				h *= s;
				
			case RATIO_FILL:
				var hs = cw / w;
				var vs = ch / h;
				
				var s = Math.max(hs, vs);
				scale.setXY(s, s);
				
				w *= s;
				h *= s;
			
			case FIXED(hpercent, vpercent):
				scale.setXY((cw * hpercent) / w, (ch * vpercent) / h);
				
				w *= scale.x;
				h *= scale.y;
				
			case NONE:
				
		}

		applyDrawingData(data, canvas);
		
		if (halign != null) {
			canvas.g2.transformation._20 = (cw - w) * halign;
		}
		
		if (valign != null) {
			canvas.g2.transformation._21 = (ch - h) * valign;
		}
		
		_cachedDrawingMatrix = canvas.g2.transformation;
		
		canvas.g2.drawImage(viewBuffer, 0, 0);
	}
	
	/**
	 * Project a point from this view to its viewport.
	 * Only works when this view is visible.
	 */
	public inline function project(x:FastFloat, y:FastFloat):Vec2 {
		return new Vec2(x, y).transformBy(_cachedDrawingMatrix.inverse());
	}

	public inline function setAlignScaleMode(halign:FastFloat, valign:FastFloat, scaleMode:ScaleMode):View {
		this.scaleMode = scaleMode;
		this.halign = halign;
		this.valign = valign;
		
		return this;
	}
	
	public inline function setCenterScaleMode(scaleMode:ScaleMode):View {
		this.scaleMode = scaleMode;
		halign = 0.5;
		valign = 0.5;
		position.setOrigin(0, 0);
		
		return this;
	}
	
	override function get_width():FastFloat {
		return viewBuffer.width;
	}
	
	override function get_height():FastFloat {
		return viewBuffer.height;
	}
	
}

enum ScaleMode {
	
	NONE;
	EXACT;
	RATIO;
	RATIO_FILL;
	FIXED(hpercent:FastFloat, vpercent:FastFloat);
	
}