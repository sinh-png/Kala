package kala.objects.text;

import kha.FastFloat;

@:allow(kala.objects.text.BasicText)
abstract Font(Dynamic) from kha.Font to kha.Font from BitmapFont to BitmapFont { 
	
	public inline function getWidth(str:String, size:UInt, bold:Bool):FastFloat {
		if (isBitmapFont()) {
			return 0;
		} else {
			var font:kha.Font = cast this;
			return font.width(size, str);
		}
	}
	
	public inline function getHeight(size:UInt):FastFloat {
		if (isBitmapFont()) {
			return 0;
		} else {
			var font:kha.Font = cast this;
			return font.height(size);
		}
	}
	
	public inline function getBaseline(size:Int):FastFloat {
		if (isBitmapFont()) {
			return 0;
		} else {
			var font:kha.Font = cast this;
			return font.baseline(size);
		}
	}

	public inline function isBitmapFont():Bool {
		return Std.is(this, BitmapFont);
	}
	
}