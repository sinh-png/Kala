package kala.util;

class StringUtil {

	public static function chars(string:String, ?eolSymbol:String = '\n'):Array<String> {
		var lines = string.split(eolSymbol);
		var array = new Array<String>();
		
		for (line in lines) {
			for (i in 0...line.length) {
				array.push(line.charAt(i));
			}
			
			array.push(eolSymbol);
		}
		
		return array;
	}
	
	public static function words(string:String, ?eolSymbol:String = '\n', ?spaceAsWord:Bool = false, ?lineFeedAsWord:Bool = false):Array<String> {
		var words = new Array<String>();
		var lines = string.split(eolSymbol);
		var wordsInLine:Array<String>;
		var lineIndex = 0;
		var wordIndex = 0;
		
		for (line in lines) {
			wordIndex = 0;
			wordsInLine = line.split(' ');
			
			for (word in wordsInLine) {
				if (word.length != 0) words.push(word);
				if (spaceAsWord && wordIndex < wordsInLine.length - 1) words.push(' ');
				wordIndex++;
			}
			
			if (lineFeedAsWord && lineIndex < lines.length - 1) words.push(eolSymbol);
			
			lineIndex++;
		}
	
		return words;
	}
	
}