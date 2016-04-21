package kala.math.color;

import kala.math.color.BlendMode.BlendFactor;
import kala.math.color.BlendMode.BlendOpt;
import kala.util.types.Trio;
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
		
		var factorsOpt = getBlendFactorsOpt(mode);
		var srcFactor = factorsOpt.a;
		var destFactor = factorsOpt.b;
		var opt = factorsOpt.c;
		
		var result:Color;
		
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
	
	public function blendEx(dest:Color, rgbBlendMode:BlendMode, alphaBlendMode:BlendMode):Color {
		var result = blend(dest, rgbBlendMode);
		
		var srcAlpha = falpha;
		var destAlpha = dest.falpha;

		var factorsOpt = getBlendFactorsOpt(alphaBlendMode);
		var srcFactor = factorsOpt.a;
		var destFactor = factorsOpt.b;
		var opt = factorsOpt.c;
		
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
	
	function getBlendFactorsOpt(mode:BlendMode):Trio<BlendFactor, BlendFactor, BlendOpt> {
		switch(mode) {
		
			case ALPHA:
				return new Trio<BlendFactor, BlendFactor, BlendOpt>(
					BlendFactor.SRC_ALPHA,
					BlendFactor.INV_SRC_ALPHA,
					BlendOpt.ADD
				);

			case ADD:
				return new Trio<BlendFactor, BlendFactor, BlendOpt>(
					BlendFactor.ONE,
					BlendFactor.ONE,
					BlendOpt.ADD
				);
				
			case SUB:
				return new Trio<BlendFactor, BlendFactor, BlendOpt>(
					BlendFactor.ONE,
					BlendFactor.ONE,
					BlendOpt.SUB
				);

			case REVERSE_SUB:
				return new Trio<BlendFactor, BlendFactor, BlendOpt>(
					BlendFactor.ONE,
					BlendFactor.ONE,
					BlendOpt.REVERSE_SUB
				);
				
			case MULTI:
				return new Trio<BlendFactor, BlendFactor, BlendOpt>(
					BlendFactor.ZERO,
					BlendFactor.SRC_COLOR,
					BlendOpt.ADD
				);

			case MULTI_2X:
				return new Trio<BlendFactor, BlendFactor, BlendOpt>(
					BlendFactor.DEST_COLOR,
					BlendFactor.SRC_COLOR,
					BlendOpt.ADD
				);

			case SET(s, d, o):
				return new Trio<BlendFactor, BlendFactor, BlendOpt>(
					s,
					d,
					o
				);
				
		}
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