package kala.components.tween;

import kha.FastFloat;

// The codes below were copied and modified from https://github.com/HaxeFlixel/flixel/blob/dev/flixel/tweens/FlxEase.hx

/*
 * Copyright (c) 2009 Adam 'Atomic' Saltsman 
 * Copyright (c) 2012 Matt Tuttle 
 * Copyright (c) 2013 HaxeFlixel Team

 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation 
 * files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
 * modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
 * is furnished to do so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
 * WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/**
 * Static class with useful easer functions that can be used by Tweens.
 * 
 * Operation of in/out easers:
 * 
 * in(t)
 * 	return t;
 * out(t)
 * 		return 1 - in(1 - t);
 * inOut(t)
 * 		return (t <= .5) ? in(t * 2) / 2 : out(t * 2 - 1) / 2 + .5;
 */
class Ease {
	
	/**
	 * Easing constants.
	 */ 
	private static var PI2:FastFloat = Math.PI / 2;
	private static var EL:FastFloat = 2 * Math.PI / .45;
	private static var B1:FastFloat = 1 / 2.75;
	private static var B2:FastFloat = 2 / 2.75;
	private static var B3:FastFloat = 1.5 / 2.75;
	private static var B4:FastFloat = 2.5 / 2.75;
	private static var B5:FastFloat = 2.25 / 2.75;
	private static var B6:FastFloat = 2.625 / 2.75;
	private static var ELASTIC_AMPLITUDE:FastFloat = 1;
	private static var ELASTIC_PERIOD:FastFloat = 0.4;

	public static inline function none(t:FastFloat):FastFloat {
		return t;
	}
	
	// Quadratic
	
	public static inline function quadIn(t:FastFloat):FastFloat {
		return t * t;
	}
	
	public static inline function quadOut(t:FastFloat):FastFloat {
		return -t * (t - 2);
	}
	
	public static inline function quadInOut(t:FastFloat):FastFloat {
		return t <= .5 ? t * t * 2 : 1 - (--t) * t * 2;
	}
	
	// Cubic
	
	public static inline function cubeIn(t:FastFloat):FastFloat {
		return t * t * t;
	}
	
	public static inline function cubeOut(t:FastFloat):FastFloat {
		return 1 + (--t) * t * t;
	}
	
	public static inline function cubeInOut(t:FastFloat):FastFloat {
		return t <= .5 ? t * t * t * 4 : 1 + (--t) * t * t * 4;
	}
	
	// Quartic

	public static inline function quartIn(t:FastFloat):FastFloat {
		return t * t * t * t;
	}
	
	public static inline function quartOut(t:FastFloat):FastFloat {
		return 1 - (t -= 1) * t * t * t;
	}
	
	public static inline function quartInOut(t:FastFloat):FastFloat {
		return t <= .5 ? t * t * t * t * 8 : (1 - (t = t * 2 - 2) * t * t * t) / 2 + .5;
	}
	
	// Quintic
	
	public static inline function quintIn(t:FastFloat):FastFloat {
		return t * t * t * t * t;
	}
	
	public static inline function quintOut(t:FastFloat):FastFloat {
		return (t = t - 1) * t * t * t * t + 1;
	}
	
	public static inline function quintInOut(t:FastFloat):FastFloat {
		return ((t *= 2) < 1) ? (t * t * t * t * t) / 2 : ((t -= 2) * t * t * t * t + 2) / 2;
	}
	
	// Sinusoidal
	
	public static inline function sineIn(t:FastFloat):FastFloat {
		return -Math.cos(PI2 * t) + 1;
	}
	
	public static inline function sineOut(t:FastFloat):FastFloat {
		return Math.sin(PI2 * t);
	}
	
	public static inline function sineInOut(t:FastFloat):FastFloat {
		return -Math.cos(Math.PI * t) / 2 + .5;
	}
	
	// Bounce
	
	public static function bounceIn(t:FastFloat):FastFloat {
		t = 1 - t;
		if (t < B1) return 1 - 7.5625 * t * t;
		if (t < B2) return 1 - (7.5625 * (t - B3) * (t - B3) + .75);
		if (t < B4) return 1 - (7.5625 * (t - B5) * (t - B5) + .9375);
		return 1 - (7.5625 * (t - B6) * (t - B6) + .984375);
	}
	
	public static function bounceOut(t:FastFloat):FastFloat {
		if (t < B1) return 7.5625 * t * t;
		if (t < B2) return 7.5625 * (t - B3) * (t - B3) + .75;
		if (t < B4) return 7.5625 * (t - B5) * (t - B5) + .9375;
		return 7.5625 * (t - B6) * (t - B6) + .984375;
	}
	
	public static function bounceInOut(t:FastFloat):FastFloat {
		if (t < .5)
		{
			t = 1 - t * 2;
			if (t < B1) return (1 - 7.5625 * t * t) / 2;
			if (t < B2) return (1 - (7.5625 * (t - B3) * (t - B3) + .75)) / 2;
			if (t < B4) return (1 - (7.5625 * (t - B5) * (t - B5) + .9375)) / 2;
			return (1 - (7.5625 * (t - B6) * (t - B6) + .984375)) / 2;
		}
		t = t * 2 - 1;
		if (t < B1) return (7.5625 * t * t) / 2 + .5;
		if (t < B2) return (7.5625 * (t - B3) * (t - B3) + .75) / 2 + .5;
		if (t < B4) return (7.5625 * (t - B5) * (t - B5) + .9375) / 2 + .5;
		return (7.5625 * (t - B6) * (t - B6) + .984375) / 2 + .5;
	}
	
	// Circular
	
	public static inline function circIn(t:FastFloat):FastFloat {
		return -(Math.sqrt(1 - t * t) - 1);
	}
	
	public static inline function circOut(t:FastFloat):FastFloat {
		return Math.sqrt(1 - (t - 1) * (t - 1));
	}
	
	public static function circInOut(t:FastFloat):FastFloat {
		return t <= .5 ? (Math.sqrt(1 - t * t * 4) - 1) / -2 : (Math.sqrt(1 - (t * 2 - 2) * (t * 2 - 2)) + 1) / 2;
	}
	
	// Exponential
	
	public static inline function expoIn(t:FastFloat):FastFloat {
		return Math.pow(2, 10 * (t - 1));
	}
	
	public static inline function expoOut(t:FastFloat):FastFloat {
		return -Math.pow(2, -10 * t) + 1;
	}
	
	public static function expoInOut(t:FastFloat):FastFloat {
		return t < .5 ? Math.pow(2, 10 * (t * 2 - 1)) / 2 : (-Math.pow(2, -10 * (t * 2 - 1)) + 2) / 2;
	}
	
	// Back
	
	public static inline function backIn(t:FastFloat):FastFloat {
		return t * t * (2.70158 * t - 1.70158);
	}
	
	public static inline function backOut(t:FastFloat):FastFloat {
		return 1 - (--t) * (t) * (-2.70158 * t - 1.70158);
	}
	
	public static function backInOut(t:FastFloat):FastFloat {
		t *= 2;
		if (t < 1) return t * t * (2.70158 * t - 1.70158) / 2;
		t--;
		return (1 - (--t) * (t) * (-2.70158 * t - 1.70158)) / 2 + .5;
	}
	
	// Elastic
	
	public static inline function elasticIn(t:FastFloat):FastFloat {
		return -(ELASTIC_AMPLITUDE * Math.pow(2, 10 * (t -= 1)) * Math.sin( (t - (ELASTIC_PERIOD / (2 * Math.PI) * Math.asin(1 / ELASTIC_AMPLITUDE))) * (2 * Math.PI) / ELASTIC_PERIOD));
	}
	
	public static inline  function elasticOut(t:FastFloat):FastFloat {
		return (ELASTIC_AMPLITUDE * Math.pow(2, -10 * t) * Math.sin((t - (ELASTIC_PERIOD / (2 * Math.PI) * Math.asin(1 / ELASTIC_AMPLITUDE))) * (2 * Math.PI) / ELASTIC_PERIOD) + 1);
	}
	
	public static function elasticInOut(t:FastFloat):FastFloat {
		if (t < 0.5) {
			return -0.5 * (Math.pow(2, 10 * (t -= 0.5)) * Math.sin((t - (ELASTIC_PERIOD / 4)) * (2 * Math.PI) / ELASTIC_PERIOD));
		}
		return Math.pow(2, -10 * (t -= 0.5)) * Math.sin((t - (ELASTIC_PERIOD / 4)) * (2 * Math.PI) / ELASTIC_PERIOD) * 0.5 + 1;
	}
	
}

typedef EaseFunction = FastFloat->FastFloat;