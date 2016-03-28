package kala.input;

@:access(kala.input.KeyStateHandle)
@:allow(kala.Kala)
class Keyboard {
	
	public static var justPressed:KeyStateHandle = new KeyStateHandle();
	public static var pressed:KeyStateHandle = new KeyStateHandle();
	public static var justReleased:KeyStateHandle = new KeyStateHandle();

	static function init():Void {
		kha.input.Keyboard.get().notify(onDown, onUp);
	}
	
	static function onDown(key:kha.Key, char:String):Void {
		var k = khaKeyToKey(key, char);
		pressed.register(k);
		justPressed.capture(k);
	}
	
	static function onUp(key:kha.Key, char:String):Void {
		var k = khaKeyToKey(key, char);
		pressed.releaseRegistered(k);
		justReleased.capture(k);
	}
	
	static inline function onPreUpdate():Void {
		justPressed.registerAllCaptured();
		justReleased.registerAllCaptured();
	}
	
	static inline function onPostUpdate():Void {
		justPressed.releaseAllRegistered();
		justReleased.releaseAllRegistered();
	}
	
	static function khaKeyToKey(key:kha.Key, char:String):Key {
		return Key.createByName(key.getName(), char.length == 0 ? null : [char]);
	}
	
}

enum Key {
	
	BACKSPACE;
	TAB;
	ENTER;
	SHIFT;
	CTRL;
	ALT;
	ESC;
	DEL;
	UP;
	DOWN;
	LEFT;
	RIGHT;
	BACK;
	CHAR(char:String);
	
}

class KeyStateHandle extends InputStateHandle<Key> {
	
	public inline function checkChar(char:String):Bool {
		return check(CHAR(char));
	}
	
	//
	
	public var ANY				(get, never):Bool; inline function get_ANY()			return checkAny();
	
	public var UP				(get, never):Bool; inline function get_UP()				return check(Key.UP);
	public var DOWN				(get, never):Bool; inline function get_DOWN()			return check(Key.DOWN);
	public var LEFT				(get, never):Bool; inline function get_LEFT()			return check(Key.LEFT);
	public var RIGHT			(get, never):Bool; inline function get_RIGHT()          return check(Key.RIGHT);
	
	public var ESC				(get, never):Bool; inline function get_ESC()			return check(Key.ESC);
	public var TAB				(get, never):Bool; inline function get_TAB()			return check(Key.TAB);
	public var SHIFT			(get, never):Bool; inline function get_SHIFT()			return check(Key.SHIFT);
	public var CTRL				(get, never):Bool; inline function get_CTRL()			return check(Key.CTRL);
	public var ALT				(get, never):Bool; inline function get_ALT()			return check(Key.ALT);
	public var BACKSPACE		(get, never):Bool; inline function get_BACKSPACE()		return check(Key.BACKSPACE);
	public var ENTER			(get, never):Bool; inline function get_ENTER()			return check(Key.ENTER);
	public var DEL				(get, never):Bool; inline function get_DEL()			return check(Key.DEL);
	public var BACK				(get, never):Bool; inline function get_BACK()			return check(Key.BACK);
	
	public var SPACE			(get, never):Bool; inline function get_SPACE()			return checkChar(' ');
	
	public var A				(get, never):Bool; inline function get_A()				return checkChar('a');
	public var B				(get, never):Bool; inline function get_B()				return checkChar('b');
	public var C				(get, never):Bool; inline function get_C()				return checkChar('c');
	public var D				(get, never):Bool; inline function get_D()				return checkChar('d');
	public var E				(get, never):Bool; inline function get_E()				return checkChar('e');
	public var F				(get, never):Bool; inline function get_F()				return checkChar('f');
	public var G				(get, never):Bool; inline function get_G()				return checkChar('g');
	public var H				(get, never):Bool; inline function get_H()				return checkChar('h');
	public var I				(get, never):Bool; inline function get_I()				return checkChar('i');
	public var J				(get, never):Bool; inline function get_J()				return checkChar('j');
	public var K				(get, never):Bool; inline function get_K()				return checkChar('k');
	public var L				(get, never):Bool; inline function get_L()				return checkChar('l');
	public var M				(get, never):Bool; inline function get_M()				return checkChar('m');
	public var N				(get, never):Bool; inline function get_N()				return checkChar('n');
	public var O				(get, never):Bool; inline function get_O()				return checkChar('o');
	public var P				(get, never):Bool; inline function get_P()				return checkChar('p');
	public var Q				(get, never):Bool; inline function get_Q()				return checkChar('q');
	public var R				(get, never):Bool; inline function get_R()				return checkChar('r');
	public var S				(get, never):Bool; inline function get_S()				return checkChar('s');
	public var T				(get, never):Bool; inline function get_T()				return checkChar('t');
	public var U				(get, never):Bool; inline function get_U()				return checkChar('u');
	public var V				(get, never):Bool; inline function get_V()				return checkChar('v');
	public var W				(get, never):Bool; inline function get_W()				return checkChar('w');
	public var X				(get, never):Bool; inline function get_X()				return checkChar('x');
	public var Y				(get, never):Bool; inline function get_Y()				return checkChar('y');
	public var Z				(get, never):Bool; inline function get_Z()				return checkChar('z');
	
	public var ZERO				(get, never):Bool; inline function get_ZERO()			return checkChar('0');
	public var ONE				(get, never):Bool; inline function get_ONE()			return checkChar('1');
	public var TWO				(get, never):Bool; inline function get_TWO()			return checkChar('2');
	public var THREE			(get, never):Bool; inline function get_THREE()			return checkChar('3');
	public var FOUR				(get, never):Bool; inline function get_FOUR()			return checkChar('4');
	public var FIVE				(get, never):Bool; inline function get_FIVE()			return checkChar('5');
	public var SIX				(get, never):Bool; inline function get_SIX()			return checkChar('6');
	public var SEVEN			(get, never):Bool; inline function get_SEVEN()			return checkChar('7');
	public var EIGHT			(get, never):Bool; inline function get_EIGHT()			return checkChar('8');
	public var NINE				(get, never):Bool; inline function get_NINE()			return checkChar('9');
	
}