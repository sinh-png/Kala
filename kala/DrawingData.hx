package kala;

import kala.math.color.BlendMode;
import kala.math.color.Color;
import kala.math.Matrix;
import kha.FastFloat;

class DrawingData {

	public var antialiasing:Bool;
	public var transformation:Matrix;
	
	public var color:Null<Color>;
	public var colorBlendMode:BlendMode;
	public var colorAlphaBlendMode:BlendMode;
	
	public var opacity:FastFloat;
	
	/**
	 * Used to send data from groups to their members throught post draw callback.
	 */
	public var extra:Dynamic;
	
	public inline function new(
		antialiasing:Bool,
		transformation:Matrix, 
		color:Null<Color>, 
		colorBlendMode:BlendMode, ?colorAlphaBlendMode:BlendMode,
		opacity:FastFloat,
		extra:Dynamic
	) {
		this.antialiasing = antialiasing;
		this.transformation = transformation;
		this.color = color;
		this.colorBlendMode = colorBlendMode;
		this.colorAlphaBlendMode = colorAlphaBlendMode;
		this.opacity = opacity;
		this.extra = extra;
	}
	
}