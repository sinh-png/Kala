package kala.objects.text;

import kala.math.Vec2;
import kala.objects.Object;
import kala.math.Color;
import kala.objects.text.Text.LineData;
import kha.Assets;
import kha.Canvas;
import kha.FastFloat;
import kha.FontStyle;
import kha.Image;
import kha.graphics2.ImageScaleQuality;
import kha.math.FastMatrix3;

using kala.math.helpers.FastMatrix3Helper;
using kala.util.StringHelper;
using StringTools;

class Text extends BasicText {
	
	var _htmlText:String;
	/**
	 * Not implemented yet.
	 */
	public var htmlText(get, set):String;
	
	public var lineSpacing:Int;
	public var fixedLineSpacing:Bool = false;
	
	public var align:TextAlign;
	
	public var contextWidth(get, null):FastFloat;
	
	public var wrapByWord(default, set):Bool = true;
	
	public var eolSymbol(default, set):String = '\n';
	
	public var padding:Vec2 = new Vec2();
	
	public var borderSize:UInt = 0;
	public var borderColor:Color = new Color();
	public var bgColor:Color = new Color(0);
	public var textColor:Color = new Color();
	public var colorBlendMode:ColorBlendMode = ColorBlendMode.NORMAL;
	
	private var _lines:Array<LineData> = new Array<LineData>();
	
	public function new(?text:String, ?font:Font, ?size:UInt = 24, ?width:UInt = 0, ?align:TextAlign) {
		super(text, font, size);
		
		this.width = width;
		this.align = align == null ? TextAlign.LEFT : align;
		
		color.set(0);
	}
	
	override public function destroy(componentsDestroy:Bool = true):Void {
		super.destroy(componentsDestroy);
		
		padding = null;
		borderColor = null;
		bgColor = null;
		textColor = null;
		
		while (_lines.length > 0) _lines.pop();
		_lines = null;
	}
	
	override public function reset(componentsReset:Bool = true):Void {
		super.reset(componentsReset);
		
		_htmlText = null;
		
		fixedLineSpacing = false;
	
		align =  TextAlign.LEFT;
		width = 0;
		wrapByWord = true;
		eolSymbol = "\n";
		
		padding.set();
		borderSize = 0;
		borderColor.set();
		bgColor.set(0);
		textColor.set();
		
		color.set(0);
		
		colorBlendMode = ColorBlendMode.NORMAL;
	}
	
	override public function draw(
		?antialiasing:Bool = false,
		?transformation:FastMatrix3, 
		?color:Color, ?colorBlendMode:ColorBlendMode,
		?opacity:FastFloat = 1,
		canvas:Canvas
	):Void {
		if (dirty) {
			refresh();
			dirty = false;
		}
		
		applyDrawingData(antialiasing, transformation, null, colorBlendMode, opacity, canvas);
		
		if (color == null) {
			color = this.color;
		} else {
			color = Color.blendColors(this.color, color, colorBlendMode);
		}
		
		var g2 = canvas.g2;
		
		g2.color = new Color().overlayBy(Color.blendColors(bgColor, color, this.colorBlendMode)).argb();
		g2.fillRect(0, 0, width, height);

		g2.color = new Color().overlayBy(Color.blendColors(borderColor, color, this.colorBlendMode)).argb();
		g2.drawRect(0, 0, width, height, borderSize);

		var defaultTextColor = new Color().overlayBy(Color.blendColors(textColor, color, this.colorBlendMode)).argb();
	
		switch(align) {
			case TextAlign.JUSTIFY:
				var contextWidth = this.contextWidth;
				var line:LineData;
				var lineWidth:FastFloat;
				var words:Array<String>;
				var tx:FastFloat;
				var ty:FastFloat = padding.y;
				var spaceSize:FastFloat ;
				
				for (i in 0..._lines.length) {
					line = _lines[i];
					tx = padding.x;
	
					words = new Array<String>();
					for (textData in line) {
						words = words.concat(textData.text.words(eolSymbol, false, false));
					}
					
					lineWidth = line.getWidth(true);
					
					if (lineWidth < contextWidth * 0.8) {
						for (textData in line) {
							g2.font = textData.font;
							g2.fontSize = textData.size;
							g2.color = textData.color == null ? defaultTextColor : new Color().overlayBy(Color.blendColors(textData.color, color, this.colorBlendMode)).argb();
							g2.drawString(textData.text, tx, ty);
							
							tx += textData.getWidth();
						}
					} else {
						spaceSize = (contextWidth - lineWidth) / (words.length - 1);
					
						if (_htmlText == null) {
							for (word in words) {
								g2.font = font;
								g2.fontSize = size;
								g2.color = defaultTextColor;
								g2.drawString(word, tx, ty);
								
								tx += font.getWidth(word, size, bold) + spaceSize;
							}
						} else {
							for (textData in line) {
								for (word in textData.text.words(eolSymbol, false, false)) {
									g2.font = textData.font;
									g2.fontSize = textData.size;
									g2.color = textData.color == null ? defaultTextColor : new Color().overlayBy(Color.blendColors(textData.color, color, this.colorBlendMode)).argb();
									
									tx += textData.font.getWidth(word, textData.size, textData.bold) + spaceSize;
								}
							}
						}
					}

					ty += line.height + lineSpacing;
				}
				
			default:
				var contextWidth = this.contextWidth;
				var tx:FastFloat = 0;
				var ty:FastFloat = padding.y;
				
				for (line in _lines) {
					if (align.equals(TextAlign.LEFT)) {
						tx = 0;
					} else if (align.equals(TextAlign.RIGHT)) {
						tx = contextWidth - line.width;
					} else {
						tx = (contextWidth - line.width) / 2;
					}
					
					tx += padding.x;
					
					for (textData in line) {
						g2.font = textData.font;
						g2.fontSize = textData.size;
						g2.color = textData.color == null ? defaultTextColor : new Color().overlayBy(Color.blendColors(textData.color, color, this.colorBlendMode)).argb();
						g2.drawString(textData.text, tx, ty);
						
						tx += textData.getWidth();
					}
					
					ty += line.height + lineSpacing;
				}
		}
		
	}
	
	override public function refresh():Void {
		if (_htmlText == null) refreshText();
		else refreshHTMLText();
	}
	
	function refreshText():Void {
		while (_lines.length > 0) _lines.pop();
		
		var array:Array<String>;
		
		if (wrapByWord) array = text.words(eolSymbol, true, true);
		else array = text.chars(eolSymbol);
		
		_height = 0;
		var lineString = "";
		
		for (s in array) {
			if (
				s != eolSymbol &&
				(_width == 0 || lineString == "" || font.getWidth(lineString + s, size, bold) <= contextWidth)
			) {
				lineString += s;
			} else {
				var line = new LineData()
						.add(new TextData(lineString, font, size, bold, italic, underlined, null))
						.refreshSize();
				_lines.push(line);
				
				_height += line.height;
				
				if (s == eolSymbol || s.isSpace(0)) lineString = "";
				else lineString = s;
			}
		}
		
		var line = new LineData()
				.add(new TextData(lineString, font, size, bold, italic, underlined, color))
				.refreshSize();
		_lines.push(line);
		
		_height += line.height;
	}
	
	function refreshHTMLText():Void {
		
	}
	
	function refreshLineSpacing():Void {
		if (fixedLineSpacing || font == null) return;
		lineSpacing = Std.int(font.getHeight(size) * 0.15);
	}
	
	override function get_width():FastFloat {
		return _width;
	}
	
	override function set_width(value:FastFloat):FastFloat {
		dirty = true;
		return _width = value;
	}
	
	override function get_height():FastFloat {
		return _height + lineSpacing * (_lines.length - 1) + padding.y * 2;
	}
	
	override function set_text(value:String):String {
		dirty = true;
		_htmlText = null;
		_text = value;
		
		for (callback in onTextChanged) callback.cbFunction(this);
		
		return value;
	}
	
	override function set_font(value:Font):Font {
		dirty = true;
		
		super.set_font(value);
		refreshLineSpacing();
		
		return font;
	}
	
	override function set_size(value:UInt):UInt {
		dirty = true;
		
		size = value;
		refreshLineSpacing();

		return value;
	}
	
	override function set_bold(value:Bool):Bool {
		dirty = true;
		return bold = value;
	}
	
	function get_contextWidth():FastFloat {
		return width - padding.x * 2;
	}
	
	function set_eolSymbol(value:String):String {
		dirty = true;
		return eolSymbol = value;
	}
	
	function set_wrapByWord(value:Bool):Bool {
		dirty = true;
		return wrapByWord = value;
	}
	
	function get_htmlText():String {
		return _htmlText == null ? _text : _htmlText;
	}
	
	function set_htmlText(value:String):String {
		dirty = true;
		return _htmlText = value;
	}
	
}

class TextData {
	
	public var text:String;
	
	public var font:Font;
	public var size:UInt;
	public var bold:Bool;
	public var italic:Bool;
	public var underlined:Bool;
	public var color:Color;
	
	public var url:String;
	
	public inline function new(
		text:String, 
		font:Font, size:UInt, bold:Bool, italic:Bool, underlined:Bool, color:Color, 
		?url:String
	) {
		this.text = text;
		
		this.font = font;
		this.size = size;
		this.bold = bold;
		this.italic = italic;
		this.underlined = underlined;
		
		this.url = url;
	}
	
	@:extern
	public inline function getWidth(excludeSpace:Bool = false):FastFloat {
		var str:String;
		if (excludeSpace) str = text.replace(' ', '');
		else str = text;
		return font.getWidth(str, size, bold);
	}
	
	@:extern
	public inline function getHeight():FastFloat {
		return font.getHeight(size);
	}

}

@:allow(kala.objects.text.Text)
class LineData {
	
	private var _texts:Array<TextData> = new Array<TextData>();
	
	public var width(default, null):FastFloat;
	public var height(default, null):FastFloat;
	
	public function new() {
		
	}
	
	public inline function iterator():Iterator<TextData> {
		return _texts.iterator();
	}
	
	public inline function add(textData:TextData):LineData {
		_texts.push(textData);
		return this;
	}
	
	public inline function getWidth(excludeSpace:Bool = false):FastFloat {
		var w:FastFloat = 0;
		
		for (text in _texts) {
			w += text.getWidth(excludeSpace);
		}
		
		return w;
	}
	
	public inline function refreshWidth(excludeSpace:Bool = false):FastFloat {
		return width = getWidth(excludeSpace); 
	}
	
	public inline function refreshHeight():FastFloat {
		height = 0;
		var textHeight:FastFloat = 0;
		
		for (text in _texts) {
			textHeight = text.getHeight();
			if (textHeight > height) height = textHeight;
		}
		
		return height;
	}
	
	public inline function refreshSize():LineData {
		refreshWidth();
		refreshHeight();
		return this;
	}
	
}