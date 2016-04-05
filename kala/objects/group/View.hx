package kala.objects.group;

import kala.DrawingData;
import kala.math.Vec2T;
import kala.objects.Object;
import kala.math.Color;
import kala.math.Rect;
import kha.Canvas;
import kha.FastFloat;
import kha.Image;
import kha.graphics4.DepthStencilFormat;
import kha.math.FastMatrix3;

@:access(kala.objects.group.Group)
class View extends Object {

	public var buffer(default, null):Image;
	
	public var viewPos:Vec2T;
	
	public var viewWidth(default, null):UInt;
	public var viewHeight(default, null):UInt;
	
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
		viewX:FastFloat, viewY:FastFloat, viewWidth:UInt, viewHeight:UInt,
		?antiAliasingSamples:UInt
	) {
		super();
		if (antiAliasingSamples == null) antiAliasingSamples = Kala.antiAliasingSamples;
		buffer = Image.createRenderTarget(
			Std.int(viewWidth), Std.int(viewHeight), null, 
			DepthStencilFormat.NoDepthAndStencil, antiAliasingSamples
		);
		
		viewPos = new Vec2T(viewX, viewY);
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
		var cw = canvas.width;
		var ch = canvas.height;
		
		var w:FastFloat = buffer.width;
		var h:FastFloat = buffer.height;
		
		if (scaleMode != null) {
			switch(scaleMode) {
				
				case EXACT:
					scale.setXY(cw / w, ch / h);
					w = cw;
					h = ch;
				
				case RATIO:
					var hs = cw / w;
					var vs = ch / h;
					
					var s = hs < vs ? hs : vs; 
					scale.setXY(s, s);
					
					w *= s;
					h *= s;
					
				case RATIO_FILL:
					var hs = cw / w;
					var vs = ch / h;
					
					var s = hs > vs ? hs : vs; 
					scale.setXY(s, s);
					
					w *= s;
					h *= s;
				
				case FIXED(hpercent, vpercent):
					scale.setXY((cw * hpercent) / w, (ch * vpercent) / h);
					
					w *= scale.x;
					h *= scale.y;
					
			}
		}
		
		if (halign != null) {
			data.transformation._20 += (cw - w) * halign;
		}
		
		if (valign != null) {
			data.transformation._21 += (ch - h) * valign;
		}
		
		applyDrawingData(data, canvas);
		canvas.g2.drawImage(buffer, 0, 0);
	}
	
	public function setAlignScaleMode(halign:FastFloat, valign:FastFloat, scaleMode:ScaleMode):View {
		this.scaleMode = scaleMode;
		this.halign = halign;
		this.valign = valign;
		
		return this;
	}
	
	public function setCenterScaleMode(scaleMode:ScaleMode):View {
		this.scaleMode = scaleMode;
		halign = 0.5;
		valign = 0.5;
		position.setOrigin(0, 0);
		
		return this;
	}
	
	override function get_width():FastFloat {
		return buffer.width;
	}
	
	override function get_height():FastFloat {
		return buffer.height;
	}
	
}

enum ScaleMode {
	EXACT;
	RATIO;
	RATIO_FILL;
	FIXED(hpercent:FastFloat, vpercent:FastFloat);
}