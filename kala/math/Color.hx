package kala.math;

import kha.FastFloat;

abstract Color(UInt) from UInt to UInt from kha.Color to kha.Color {
	
	public static inline function fromBytes(alpha:UInt, red:UInt, green:UInt, blue:UInt):Color {
		return (alpha << 24) | (red << 16 ) | (green << 8) | blue;
	}
	
	public static inline function fromFloats(alpha:FastFloat, red:FastFloat, green:FastFloat, blue:FastFloat):Color {
		return fromBytes(
			Std.int(Math.abs(alpha * 255)),
			Std.int(Math.abs(red * 255)),
			Std.int(Math.abs(green * 255)),
			Std.int(Math.abs(blue * 255))
		);
	}
	
	static inline function getBlendColor(
		src:Color, dest:Color, colorBlendMode:BlendMode, colorAlphaBlendMode:BlendMode
	):Color {
		if (colorAlphaBlendMode == null) {
			return src.blend(dest, colorBlendMode); 
		}
			
		return src.blendEx(dest, colorBlendMode, colorAlphaBlendMode);
	}
	
	//
	
	public var alpha(get, set):UInt;
	public var red(get, set):UInt;
	public var green(get, set):UInt;
	public var blue(get, set):UInt;
	
	public var falpha(get, set):FastFloat;
	public var fred(get, set):FastFloat;
	public var fgreen(get, set):FastFloat;
	public var fblue(get, set):FastFloat;
	
	public inline function setBytes(alpha:UInt, red:UInt, green:UInt, blue:UInt):Void {
		this = (alpha << 24) | (red << 16 ) | (green << 8) | blue;
	}
	
	public inline function setFloats(alpha:FastFloat, red:FastFloat, green:FastFloat, blue:FastFloat):Void {
		setBytes(
			Std.int(Math.abs(alpha * 255)),
			Std.int(Math.abs(red * 255)),
			Std.int(Math.abs(green * 255)),
			Std.int(Math.abs(blue * 255))
		);
	}
	
	public function blend(dest:Color, mode:BlendMode):Color {
		
		var srcAlpha = falpha;
		var srcRed = fred;
		var srcGreen = fgreen;
		var srcBlue = fblue;
		
		var destAlpha = dest.falpha;
		var destRed = dest.fred;
		var destGreen = dest.fgreen;
		var destBlue = dest.fblue;
		
		var srcFactor:BlendFactor;
		var destFactor:BlendFactor;
		
		var opt:BlendOpt;
		
		var result:Color;

		switch(mode) {
		
			case ALPHA:
				srcFactor = BlendFactor.SRC_ALPHA;
				destFactor = BlendFactor.INV_SRC_ALPHA;
				opt = BlendOpt.ADD;
				
			case ADD:
				srcFactor = BlendFactor.ONE;
				destFactor = BlendFactor.ONE;
				opt = BlendOpt.ADD;
				
			case MULTI:
				srcFactor = BlendFactor.ZERO;
				destFactor = BlendFactor.SRC_COLOR;
				opt = BlendOpt.ADD;
				
			case MULTI_2X:
				srcFactor = BlendFactor.DEST_COLOR;
				destFactor = BlendFactor.SRC_COLOR;
				opt = BlendOpt.ADD;
			
			case SET(s, d, o):
				srcFactor = s;
				destFactor = d;
				opt = o;
				
		}
		
		switch(srcFactor) {
	
			case ZERO:
				srcAlpha = srcRed = srcGreen = srcBlue = 0;

			case ONE:
				
			//
				
			case SRC_ALPHA:
				srcAlpha *= srcAlpha;
				srcRed *= srcAlpha;
				srcGreen *= srcAlpha;
				srcBlue *= srcAlpha;
				
			case INV_SRC_ALPHA:
				srcAlpha *= 1 - srcAlpha;
				srcRed *= 1 - srcAlpha;
				srcGreen *= 1 - srcAlpha;
				srcBlue *= 1 - srcAlpha;
				
			case SRC_COLOR:
				srcAlpha *= srcAlpha;
				srcRed *= srcRed;
				srcGreen *= srcGreen;
				srcBlue *= srcBlue;
				
			case INV_SRC_COLOR:
				srcAlpha *= 1 - srcAlpha;
				srcRed *= 1 - srcRed;
				srcGreen *= 1 - srcGreen;
				srcBlue *= 1 - srcBlue;
				
			//
				
			case DEST_ALPHA:
				srcAlpha *= destAlpha;
				srcRed *= destAlpha;
				srcGreen *= destAlpha;
				srcBlue *= destAlpha;
				
			case INV_DEST_ALPHA:
				srcAlpha *= 1 - destAlpha;
				srcRed *= 1 - destAlpha;
				srcGreen *= 1 - destAlpha;
				srcBlue *= 1 - destAlpha;
				
			case DEST_COLOR:
				srcAlpha *= destAlpha;
				srcRed *= destRed;
				srcGreen *= destGreen;
				srcBlue *= destBlue;
				
			case INV_DEST_COLOR:
				srcAlpha *= 1 - destAlpha;
				srcRed *= 1 - destRed;
				srcGreen *= 1 - destGreen;
				srcBlue *= 1 - destBlue;
				
			case SRC_ALPHA_SATURATION:
				var f = Math.min(srcAlpha, 1 - srcAlpha);
				srcRed *= f;
				srcGreen *= f;
				srcBlue *= f;
				
			case DEST_ALPHA_SATURATION:
				var f = Math.min(destAlpha, 1 - destAlpha);
				srcRed *= f;
				srcGreen *= f;
				srcBlue *= f;
				
			case SET(a, r, g, b):
				srcAlpha *= a;
				srcRed *= r;
				srcGreen *= g;
				srcBlue *= b;
				
		}
		
		switch(destFactor) {
	
			case ZERO:
				destAlpha = destRed = destGreen = destBlue = 0;

			case ONE:
				
			//
				
			case SRC_ALPHA:
				destAlpha *= srcAlpha;
				destRed *= srcAlpha;
				destGreen *= srcAlpha;
				destBlue *= srcAlpha;
				
			case INV_SRC_ALPHA:
				destAlpha *= 1 - srcAlpha;
				destRed *= 1 - srcAlpha;
				destGreen *= 1 - srcAlpha;
				destBlue *= 1 - srcAlpha;
				
			case SRC_COLOR:
				destAlpha *= srcAlpha;
				destRed *= srcRed;
				destGreen *= srcGreen;
				destBlue *= srcBlue;
				
			case INV_SRC_COLOR:
				destAlpha *= 1 - srcAlpha;
				destRed *= 1 - srcRed;
				destGreen *= 1 - srcGreen;
				destBlue *= 1 - srcBlue;
				
			//
				
			case DEST_ALPHA:
				destAlpha *= destAlpha;
				destRed *= destAlpha;
				destGreen *= destAlpha;
				destBlue *= destAlpha;
				
			case INV_DEST_ALPHA:
				destAlpha *= 1 - destAlpha;
				destRed *= 1 - destAlpha;
				destGreen *= 1 - destAlpha;
				destBlue *= 1 - destAlpha;
				
			case DEST_COLOR:
				destAlpha *= destAlpha;
				destRed *= destRed;
				destGreen *= destGreen;
				destBlue *= destBlue;
				
			case INV_DEST_COLOR:
				destAlpha *= 1 - destAlpha;
				destRed *= 1 - destRed;
				destGreen *= 1 - destGreen;
				destBlue *= 1 - destBlue;
				
			case SRC_ALPHA_SATURATION:
				var f = Math.min(srcAlpha, 1 - srcAlpha);
				destRed *= f;
				destGreen *= f;
				destBlue *= f;
				
			case DEST_ALPHA_SATURATION:
				var f = Math.min(destAlpha, 1 - destAlpha);
				destRed *= f;
				destGreen *= f;
				destBlue *= f;
				
			case SET(a, r, g, b):
				destAlpha *= a;
				destRed *= r;
				destGreen *= g;
				destBlue *= b;
				
		}
		
		switch(opt) {
			
			case BlendOpt.ADD:
				result = fromFloats(srcAlpha + destAlpha, srcRed + destRed, srcGreen + destGreen, srcBlue + destBlue);
				
			case BlendOpt.SUB:
				result = fromFloats(srcAlpha - destAlpha, srcRed - destRed, srcGreen - destGreen, srcBlue - destBlue);
				
			case BlendOpt.REVERSE_SUB:
				result = fromFloats(destAlpha - srcAlpha, destRed - srcRed, destGreen - srcGreen, destBlue - srcBlue);
			
			case BlendOpt.MAX:
				result = fromFloats(
					Math.max(srcAlpha, destAlpha),
					Math.max(srcRed, destRed),
					Math.max(srcGreen, destGreen),
					Math.max(srcBlue, destBlue)
				);
				
			case BlendOpt.MIN:
				result = fromFloats(
					Math.min(srcAlpha, destAlpha),
					Math.min(srcRed, destRed),
					Math.min(srcGreen, destGreen),
					Math.min(srcBlue, destBlue)
				);
			
		}
			
		
		return result;
	}
	
	public function blendEx(dest:Color, rgbMode:BlendMode, alphaMode:BlendMode):Color {
		var result = blend(dest, rgbMode);
		
		var srcAlpha = falpha;
		var destAlpha = dest.falpha;

		var srcFactor:BlendFactor;
		var destFactor:BlendFactor;
		
		var opt:BlendOpt;

		switch(alphaMode) {
		
			case ALPHA:
				srcFactor = BlendFactor.SRC_ALPHA;
				destFactor = BlendFactor.INV_SRC_ALPHA;
				opt = BlendOpt.ADD;
				
			case ADD:
				srcFactor = BlendFactor.ONE;
				destFactor = BlendFactor.ONE;
				opt = BlendOpt.ADD;
				
			case MULTI:
				srcFactor = BlendFactor.ZERO;
				destFactor = BlendFactor.SRC_COLOR;
				opt = BlendOpt.ADD;
				
			case MULTI_2X:
				srcFactor = BlendFactor.DEST_COLOR;
				destFactor = BlendFactor.SRC_COLOR;
				opt = BlendOpt.ADD;
			
			case SET(s, d, o):
				srcFactor = s;
				destFactor = d;
				opt = o;
				
		}
		
		switch(srcFactor) {
	
			case ZERO:
				srcAlpha = 0;

			case ONE:
				
			//
				
			case SRC_ALPHA:
				srcAlpha *= srcAlpha;
				
			case INV_SRC_ALPHA:
				srcAlpha *= 1 - srcAlpha;
				
			case SRC_COLOR:
				srcAlpha *= srcAlpha;
				
			case INV_SRC_COLOR:
				srcAlpha *= 1 - srcAlpha;
				
			//
				
			case DEST_ALPHA:
				srcAlpha *= destAlpha;
				
			case INV_DEST_ALPHA:
				srcAlpha *= 1 - destAlpha;
				
			case DEST_COLOR:
				srcAlpha *= destAlpha;

			case INV_DEST_COLOR:
				srcAlpha *= 1 - destAlpha;

			case SRC_ALPHA_SATURATION:
				srcAlpha *= Math.min(srcAlpha, 1 - srcAlpha);

			case DEST_ALPHA_SATURATION:
				srcAlpha *= Math.min(destAlpha, 1 - destAlpha);
				
			case SET(a, _, _, _):
				srcAlpha *= a;
				
		}
		
		switch(destFactor) {
	
			case ZERO:
				destAlpha = 0;

			case ONE:
				
			//
				
			case SRC_ALPHA:
				destAlpha *= srcAlpha;
				
			case INV_SRC_ALPHA:
				destAlpha *= 1 - srcAlpha;
				
			case SRC_COLOR:
				destAlpha *= srcAlpha;
				
			case INV_SRC_COLOR:
				destAlpha *= 1 - srcAlpha;
				
			//
				
			case DEST_ALPHA:
				destAlpha *= destAlpha;
				
			case INV_DEST_ALPHA:
				destAlpha *= 1 - destAlpha;
				
			case DEST_COLOR:
				destAlpha *= destAlpha;

			case INV_DEST_COLOR:
				destAlpha *= 1 - destAlpha;

			case SRC_ALPHA_SATURATION:
				destAlpha *= Math.min(srcAlpha, 1 - srcAlpha);

			case DEST_ALPHA_SATURATION:
				destAlpha *= Math.min(destAlpha, 1 - destAlpha);
				
			case SET(a, _, _, _):
				destAlpha *= a;
				
		}
		
		switch(opt) {
			
			case BlendOpt.ADD:
				result.falpha = srcAlpha + destAlpha;
				
			case BlendOpt.SUB:
				result.falpha = srcAlpha - destAlpha;
				
			case BlendOpt.REVERSE_SUB:
				result.falpha = destAlpha - srcAlpha;
			
			case BlendOpt.MAX:
				result.falpha = Math.max(srcAlpha, destAlpha);
				
			case BlendOpt.MIN:
				result.falpha = Math.min(srcAlpha, destAlpha);
			
		}
		
		return result;
	}
	
	public inline function blendBy(dest:Color, mode:BlendMode):Color {
		return this = blend(dest, mode);
	}
	
	public inline function blendExBy(dest:Color, rgbMode:BlendMode, alphaMode:BlendMode):Color {
		return this = blendEx(dest, rgbMode, alphaMode);
	}
	
	//
	
	inline function get_alpha():UInt {
		return (this >> 24) & 0xff;
	}
	
	inline function set_alpha(value:UInt):UInt {
		setBytes(value, red, green, blue);
		return value;
	}
	
	inline function get_red():UInt {
		return (this >> 16) & 0xff;
	}
	
	inline function set_red(value:UInt):UInt {
		setBytes(alpha, value, green, blue);
		return value;
	}
	
	inline function get_green():UInt {
		return (this >> 8) & 0xff;
	}
	
	inline function set_green(value:UInt):UInt {
		setBytes(alpha, red, value, blue);
		return value;
	}
	
	inline function get_blue():UInt {
		return this & 0xff;
	}
	
	inline function set_blue(value:UInt):UInt {
		setBytes(alpha, red, green, value);
		return value;
	}
	
	//
	
	inline function get_falpha():FastFloat {
		return alpha / 255;
	}
	
	inline function set_falpha(value:FastFloat):FastFloat {
		setBytes(Std.int(Math.abs(value * 255)), red, green, blue);
		return value;
	}
	
	inline function get_fred():FastFloat {
		return red / 255;
	}
	
	inline function set_fred(value:FastFloat):FastFloat {
		setBytes(alpha, Std.int(Math.abs(value * 255)), green, blue);
		return value;
	}
	
	inline function get_fgreen():FastFloat {
		return green / 255;
	}
	
	inline function set_fgreen(value:FastFloat):FastFloat {
		setBytes(alpha, red, Std.int(Math.abs(value * 255)), blue);
		return value;
	}
	
	inline function get_fblue():FastFloat {
		return blue / 255;
	}
	
	inline function set_fblue(value:FastFloat):FastFloat {
		setBytes(alpha, red, green, Std.int(Math.abs(value * 255)));
		return value;
	}
	
}

enum BlendOpt {
	
	ADD;
	SUB;
	REVERSE_SUB;
	MAX;
	MIN;
	
}

enum BlendFactor {
	
	ZERO;
	ONE;
	
	SRC_ALPHA;
	INV_SRC_ALPHA;
	
	SRC_COLOR;
	INV_SRC_COLOR;

	DEST_ALPHA;
	INV_DEST_ALPHA;
	
	DEST_COLOR;
	INV_DEST_COLOR;
	
	SRC_ALPHA_SATURATION;
	DEST_ALPHA_SATURATION;
	
	SET(a:FastFloat, r:FastFloat, g:FastFloat, b:FastFloat);
	
}

enum BlendMode {
	
	ALPHA;
	ADD;
	MULTI;
	MULTI_2X;
	SET(src:BlendFactor, dest:BlendFactor, opt:BlendOpt);
	
}

/*
// TODO: Rewrite thic class to an abstract of kha.Color or UInt.
class Color {
	
	@:extern
	public static inline function fromARGB(argb:UInt):Color {
		return new Color().setARGB(argb);
	}
	
	@:extern
	public static inline function fromComponents(alpha:Float, red:UInt, green:UInt, blue:UInt):Color {
		return new Color().setComponents(alpha, red, green, blue);
	}
	
	@:extern
	public static inline function blendColors(backgroundColor:Color, foregroundColor:Color, ?blendMode:ColorBlendMode):Color {
		return new Color(backgroundColor.alpha, backgroundColor.rgb).setBlend(foregroundColor, blendMode);
	}
	
	//
	
	public var alpha:FastFloat;
	public var rgb:UInt;
	
	public inline function new(alpha:FastFloat = 1, rgb:UInt = 0xffffff) {
		this.alpha = alpha;
		this.rgb = rgb;
	}
	
	@:extern
	public inline function set(alpha:FastFloat = 1, rgb:UInt = 0xffffff):Color {
		this.alpha = alpha;
		this.rgb = rgb;
		
		correctAlpha();
		
		return this;
	}
	
	@:extern 
	public inline function copy(color:Color):Color {
		alpha = color.alpha;
		rgb = color.rgb;
		return this;
	}
	
	@:extern
	public inline function clone():Color {
		return new Color(alpha, rgb);
	}
	
	@:extern
	public inline function setRGBComponents(red:UInt, green:UInt, blue:UInt):Color {
		rgb = (red << 16 ) | (green << 8) | blue;
		return this;
	}
	
	@:extern
	public inline function setARGB(argb:UInt):Color {
		alpha = ((argb >> 24) & 0xFF) / 255;
		rgb = 0xFFFFFF & argb;
		
		return this;
	}
	
	@:extern
	public inline function setComponents(alpha:FastFloat, red:UInt, green:UInt, blue:UInt):Color {
		this.alpha = alpha;
		setRGBComponents(red, green, blue);
		return this;
	}
	
	@:extern
	public inline function red():UInt {
		return (rgb >> 16) & 0xff;
	}
	
	@:extern
	public inline function green():UInt {
		return (rgb >> 8) & 0xff;
	}
	
	@:extern
	public inline function blue():UInt {
		return rgb & 0xff;
	}
	
	@:extern
	public inline function argb():UInt {
		correctAlpha();
		return Std.int(alpha * 255) << 24 | rgb;
	}
	
	@:extern
	public inline function setBlend(color:Color, ?blendMode:ColorBlendMode):Color {
		correctAlpha();
		color.correctAlpha();
		
		if (blendMode == null) blendMode = NORMAL;
		
		switch(blendMode) {
			case NORMAL:
				var a = color.alpha + (this.alpha * (1 - color.alpha));
				var r = (color.red() * color.alpha) + (this.red() * (1 - color.alpha));
				var g = (color.green() * color.alpha) + (this.green() * (1 - color.alpha));
				var b = (color.blue() * color.alpha) + (this.blue() * (1 - color.alpha));
				
				setComponents(a, Std.int(r), Std.int(g), Std.int(b));
				
			case ADD:
				var a = color.alpha + this.alpha;
				var r = color.red() * color.alpha + this.red() * this.alpha;
				var g = color.green() * color.alpha + this.green() * this.alpha;
				var b = color.blue() * color.alpha + this.blue() * this.alpha;
				
				setComponents(a, Std.int(r), Std.int(g), Std.int(b));
				
			case OVERLAY:
				var r = (color.red() * color.alpha) + (this.red() * (1 - color.alpha));
				var g = (color.green() * color.alpha) + (this.green() * (1 - color.alpha));
				var b = (color.blue() * color.alpha) + (this.blue() * (1 - color.alpha));
				
				setRGBComponents(Std.int(r), Std.int(g), Std.int(b));
				
			case AVERAGE:
				var a = Std.int((color.alpha + this.alpha) / 2);
				var r = Std.int((color.red() + this.red()) / 2);
				var g = Std.int((color.green() + this.green()) / 2);
				var b = Std.int((color.blue() + this.blue()) / 2);
				
				setComponents(a, r, g, b);
				
			case MIX:
				var a = color.alpha * this.alpha;
				var r = color.red() + this.red();
				var g = color.green() + this.green();
				var b = color.blue() + this.blue();
				
				setComponents(a, r, g, b);
		}
		
		return this;
	}
	
	@:extern
	public inline function setBlendARGB(argb:UInt, ?blendMode:ColorBlendMode):Color {
		var color = Color.fromARGB(argb);
		setBlend(color, blendMode);
		
		return this;
	}
	
	@:extern
	public inline function setOverlay(color:Color):Color {
		setBlend(color, OVERLAY);
		return this;
	}
	
	@:extern
	public inline function correctAlpha():Void {
		if (alpha > 1) alpha = 1;
		else if (alpha < 0) alpha = 0;	
	}
	
}*/
