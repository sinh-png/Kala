package kala;

import kala.math.color.BlendMode;
import kala.math.color.Color;
import kala.math.Matrix;
import kha.FastFloat;

class DrawingData {

	public var antialiasing:Bool;
	public var transformation:Matrix;
	
	public var color:Null<Color>;
	public var colorBlendMode:BlendMode = BlendMode.ADD;
	public var colorAlphaBlendMode:BlendMode = null;
	
	public var opacity:FastFloat;
	
	public inline function new(
		?antialiasing:Bool = false,
		?transformation:Matrix, 
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