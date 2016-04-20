package kala;

import kala.math.Color;
import kha.FastFloat;
import kha.math.FastMatrix3;

class DrawingData {

	public var antialiasing:Bool;
	public var transformation:FastMatrix3;
	
	public var color:Color;
	public var colorBlendMode:BlendMode = BlendMode.ADD;
	public var colorAlphaBlendMode:BlendMode = null;
	
	public var opacity:FastFloat;
	
	public inline function new(
		?antialiasing:Bool = false,
		?transformation:FastMatrix3, 
		?color:Color, 
		?colorBlendMode:BlendMode, ?colorAlphaBlendMode:BlendMode,
		?opacity:FastFloat = 1
	) {
		this.antialiasing = antialiasing;
		this.transformation = transformation;
		this.color = color;
		this.colorBlendMode = colorBlendMode;
		this.colorAlphaBlendMode = colorAlphaBlendMode;
		this.opacity = opacity;
	}
	
}