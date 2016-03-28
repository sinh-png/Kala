package kala.objects.text;

import kala.EventHandle.CallbackHandle;
import kala.math.Color;
import kala.math.Color.ColorBlendMode;
import kala.objects.Object;
import kha.Canvas;
import kha.FastFloat;
import kha.math.FastMatrix3;

class BasicText extends Object {

	var _text:String;
	public var text(get, set):String;
	
	public var font(default, set):Font;
	
	public var size(default, set):UInt;
	public var bold(default, set):Bool = false;
	public var italic:Bool = false;
	public var underlined:Bool = false;
	
	public var onTextChanged:CallbackHandle<BasicText->Void>;
	
	public function new(?text:String, ?font:Font, ?size:UInt = 24) {
		super();

		_text = text;
		
		this.size = size;
		this.font = font;
		
		onTextChanged = addCBHandle(new CallbackHandle<BasicText->Void>());
	}

	override public function destroy(componentsDestroy:Bool = true):Void {
		super.destroy(componentsDestroy);
		font = null;
		onTextChanged = null;
	}
	
	override public function reset(componentsReset:Bool = true):Void {
		_text = null;
		
		font = Kala.defaultFont;
		
		size = 24;
		bold = false;
		italic = false;
		underlined = false;
		
		super.reset(componentsReset);
	}
	
	override public function draw(
		?antialiasing:Bool = false,
		?transformation:FastMatrix3, 
		?color:Color, ?colorBlendMode:ColorBlendMode, 
		?opacity:FastFloat = 1, 
		canvas:Canvas
	):Void {
		applyDrawingData(antialiasing, transformation, color, colorBlendMode, opacity, canvas);
		var g2 = canvas.g2;
		g2.font = font;
		g2.fontSize = size;
		g2.drawString(text, 0, 0);
	}
	
	override public function isVisible():Bool {
		return super.isVisible() && _text != null && _text.length > 0 && font != null && size > 0;
	}
	
	override function get_width():FastFloat {
		return font.getWidth(text, size, bold);
	}
	
	override function get_height():FastFloat {
		return font.getHeight(size);
	}
	
	function get_text():String {
		return _text;
	}
	
	function set_text(value:String):String {
		_text = value;
		for (callback in onTextChanged) callback.cbFunction(this);
		return value;
	}
	
	function set_font(value:Font):Font {
		if (value == null) font = Kala.defaultFont;
		else font = value;
		return font;
	}
	
	function set_size(value:UInt):UInt {
		return size = value;
	}
	
	function set_bold(value:Bool):Bool {
		return bold = value;
	}
	
}