package kala.objects.text;

import kala.math.color.BlendMode;
import kala.math.Vec2;
import kala.objects.Object;
import kala.math.color.Color;
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

@:access(kala.math.color.Color)
class Text extends BasicText {
	
	var _htmlText:String;
	public var htmlText(get, set):String;
	
	public var lineSpacing:Int;
	public var fixedLineSpacing:Bool;
	
	public var align:TextAlign;
	
	/**
	 * The width of this text without padding.
	 */
	public var contentWidth(get, null):FastFloat;
	
	public var wrapByWord(default, set):Bool;
	
	public var eolSymbol(default, set):String;
	
	public var padding:Vec2 = new Vec2();
	
	public var borderSize:UInt;
	public var borderColor:Color = Color.WHITE;
	public var borderOpacity:FastFloat;
	
	public var bgColor:Color = Color.WHITE;
	public var bgOpacity:FastFloat;
	
	public var textColor:Color = Color.WHITE;
	public var textOpacity:FastFloat;
	
	public var colorBlendMode:BlendMode = BlendMode.ADD;
	public var colorAlphaBlendMode:BlendMode = null;
	
	private var _dirty:Bool;
	
	private var _lines:Array<LineData> = new Array<LineData>();
	
	public function new(?text:String, ?font:Font, ?size:UInt = 24, ?width:UInt = 0, ?align:TextAlign) {
		super(text, font, size);
		
		this.width = width;
		this.align = align == null ? TextAlign.LEFT : align;
		
		if (text != null) refreshText();
	}
	
	override public function reset(resetBehaviors:Bool = false):Void {
		super.reset(resetBehaviors);
		
		_htmlText = null;
		
		fixedLineSpacing = false;
	
		align =  TextAlign.LEFT;
		width = 0;
		wrapByWord = true;
		eolSymbol = "\n";
		
		padding.set();
		
		borderSize = 1;
		borderColor = Color.WHITE;
		borderOpacity = 0;
		
		bgColor = Color.WHITE;
		bgOpacity = 0;
		
		textColor = Color.WHITE;
		textOpacity = 1;
		
		color = Color.TRANSPARENT;
		
		colorBlendMode = BlendMode.ADD;
		colorAlphaBlendMode = null;
	}
	
	override public function destroy(destroyBehaviors:Bool = true):Void {
		super.destroy(destroyBehaviors);
		padding = null;
		_lines = null;
	}
		
	override public function draw(data:DrawingData, canvas:Canvas):Void {
		if (_dirty) {
			if (_htmlText == null) refreshText();
			else refreshHTMLText();
			
			_dirty = false;
		}

		data.color = null;
		applyDrawingData(data, canvas);
		
		var g2 = canvas.g2;
		var color:Color = g2.color;
		opacity = g2.opacity;
		
		if (bgOpacity > 0) {
			g2.color = Color.getBlendColor(bgColor, color, colorBlendMode, colorAlphaBlendMode);
			g2.opacity = opacity * bgOpacity;
			g2.fillRect(0, 0, width, height);
		}
		
		if (borderOpacity > 0 || borderSize > 0) {
			g2.color = Color.getBlendColor(borderColor, color, colorBlendMode, colorAlphaBlendMode);
			g2.opacity = opacity * borderOpacity;
			g2.drawRect(0, 0, width, height, borderSize);
		}

		var defaultTextColor = Color.getBlendColor(textColor, color, colorBlendMode, colorAlphaBlendMode);
		g2.opacity = opacity * textOpacity;
		
		switch(align) {
			case TextAlign.JUSTIFY:
				var contentWidth = this.contentWidth;
				var line:LineData;
				var lineWidth:FastFloat;
				var words:Array<String>;
				var tx:FastFloat;
				var ty:FastFloat = padding.y;
				var spaceSize:FastFloat;
				
				for (i in 0..._lines.length) {
					line = _lines[i];
					tx = padding.x;
	
					words = new Array<String>();
					for (textData in line) {
						words = words.concat(textData.text.words(eolSymbol, false, false));
					}
					
					lineWidth = line.getWidth(true);
					
					if (lineWidth < contentWidth * 0.8) {
						for (textData in line) {
							g2.font = textData.font;
							g2.fontSize = textData.size;
							g2.color = textData.color == null ? defaultTextColor : Color.getBlendColor(textData.color, color, colorBlendMode, colorAlphaBlendMode);
							g2.drawString(textData.text, tx, ty);
							
							tx += textData.getWidth();
						}
					} else {
						spaceSize = (contentWidth - lineWidth) / (words.length - 1);
					
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
									g2.color = textData.color == null ? defaultTextColor : Color.getBlendColor(textData.color, color, colorBlendMode, colorAlphaBlendMode);
									
									tx += textData.font.getWidth(word, textData.size, textData.bold) + spaceSize;
								}
							}
						}
					}

					ty += line.height + lineSpacing;
				}
				
			default:
				var contentWidth = this.contentWidth;
				var tx:FastFloat = 0;
				var ty:FastFloat = padding.y;
				
				for (line in _lines) {
					if (align.equals(TextAlign.LEFT)) {
						tx = 0;
					} else if (align.equals(TextAlign.RIGHT)) {
						tx = contentWidth - line.width;
					} else {
						tx = (contentWidth - line.width) / 2;
					}
					
					tx += padding.x;
					
					for (textData in line) {
						g2.font = textData.font;
						g2.fontSize = textData.size;
						g2.color = textData.color == null ? defaultTextColor : Color.getBlendColor(textData.color, color, colorBlendMode, colorAlphaBlendMode);
						g2.drawString(textData.text, tx, ty);
						
						tx += textData.getWidth();
					}
					
					ty += line.height + lineSpacing;
				}
		}
		
	}
	
	function refreshText():Void {
		_lines.splice(0, _lines.length);
		
		var array:Array<String>;
		
		if (wrapByWord) array = text.words(eolSymbol, true, true);
		else array = text.chars(eolSymbol);
		
		_height = 0;
		var lineString = "";
		
		for (s in array) {
			if (
				s != eolSymbol &&
				(_width == 0 || lineString == "" || font.getWidth(lineString + s, size, bold) <= contentWidth)
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
		_dirty = true;
		return _width = value;
	}

	override function get_height():FastFloat {
		return _height + lineSpacing * (_lines.length - 1) + padding.y * 2;
	}
	
	override function set_text(value:String):String {
		_dirty = true;
		_htmlText = null;
		_text = value;
		
		for (callback in onTextChange) callback.cbFunction(this);
		
		return value;
	}
	
	override function set_font(value:Font):Font {
		_dirty = true;
		
		super.set_font(value);
		refreshLineSpacing();
		
		return font;
	}
	
	override function set_size(value:UInt):UInt {
		_dirty = true;
		
		size = value;
		refreshLineSpacing();

		return value;
	}
	
	override function set_bold(value:Bool):Bool {
		_dirty = true;
		return bold = value;
	}
	
	function get_contentWidth():FastFloat {
		return width - padding.x * 2;
	}
	
	function set_eolSymbol(value:String):String {
		_dirty = true;
		return eolSymbol = value;
	}
	
	function set_wrapByWord(value:Bool):Bool {
		_dirty = true;
		return wrapByWord = value;
	}
	
	function get_htmlText():String {
		return _htmlText == null ? _text : _htmlText;
	}
	
	function set_htmlText(value:String):String {
		_dirty = true;
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
	public var color:Null<Color>;
	
	public var url:String;
	
	public inline function new(
		text:String, 
		font:Font, size:UInt, bold:Bool, italic:Bool, underlined:Bool, ?color:Color, 
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