package kala.math;

import kha.FastFloat;

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
		return new Color(backgroundColor.alpha, backgroundColor.rgb).blend(foregroundColor, blendMode);
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
	public inline function blend(color:Color, ?blendMode:ColorBlendMode):Color {
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
	public inline function blendARGB(argb:UInt, ?blendMode:ColorBlendMode):Color {
		var color = Color.fromARGB(argb);
		blend(color, blendMode);
		
		return this;
	}
	
	@:extern
	public inline function correctAlpha():Void {
		if (alpha > 1) alpha = 1;
		else if (alpha < 0) alpha = 0;	
	}
	
}

enum ColorBlendMode {
	NORMAL;
	ADD;
	OVERLAY;
	AVERAGE;
	MIX;
}