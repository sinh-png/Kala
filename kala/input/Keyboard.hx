package kala.input;

#if (debug || kala_debug || kala_keyboard)

import kala.EventHandle.CallbackHandle;
import kala.input.ButtonInputHandle;
import kha.FastFloat;
import kha.Key;

@:allow(kala.Kala)
@:access(kala.CallbackHandle)
@:access(kala.input.ButtonInput)
class Keyboard {
	
	public static var onStartPressing(default, never):CallbackHandle<Key->Void> = new CallbackHandle<Key->Void>();
	public static var onRelease(default, never):CallbackHandle<Key->Void> = new CallbackHandle<Key->Void>();

	//
	
	public static var ANY(default, null):ButtonInput<Key>;
	
	public static var LEFT(default, null):ButtonInput<Key>;
	public static var RIGHT(default, null):ButtonInput<Key>;
	public static var UP(default, null):ButtonInput<Key>;
	public static var DOWN(default, null):ButtonInput<Key>;
	
	public static var ESC(default, null):ButtonInput<Key>;
	public static var TAB(default, null):ButtonInput<Key>;
	public static var SHIFT(default, null):ButtonInput<Key>;
	public static var CTRL(default, null):ButtonInput<Key>;
	public static var ALT(default, null):ButtonInput<Key>;
	public static var BACKSPACE(default, null):ButtonInput<Key>;
	public static var ENTER(default, null):ButtonInput<Key>;
	public static var DEL(default, null):ButtonInput<Key>;
	public static var BACK(default, null):ButtonInput<Key>;
	
	public static var SPACE(default, null):ButtonInput<Key>;
	
	public static var A(default, null):ButtonInput<Key>;
	public static var B(default, null):ButtonInput<Key>;
	public static var C(default, null):ButtonInput<Key>;
	public static var D(default, null):ButtonInput<Key>;
	public static var E(default, null):ButtonInput<Key>;
	public static var F(default, null):ButtonInput<Key>;
	public static var G(default, null):ButtonInput<Key>;
	public static var H(default, null):ButtonInput<Key>;
	public static var I(default, null):ButtonInput<Key>;
	public static var J(default, null):ButtonInput<Key>;
	public static var K(default, null):ButtonInput<Key>;
	public static var L(default, null):ButtonInput<Key>;
	public static var M(default, null):ButtonInput<Key>;
	public static var N(default, null):ButtonInput<Key>;
	public static var O(default, null):ButtonInput<Key>;
	public static var P(default, null):ButtonInput<Key>;
	public static var Q(default, null):ButtonInput<Key>;
	public static var R(default, null):ButtonInput<Key>;
	public static var S(default, null):ButtonInput<Key>;
	public static var T(default, null):ButtonInput<Key>;
	public static var U(default, null):ButtonInput<Key>;
	public static var V(default, null):ButtonInput<Key>;
	public static var W(default, null):ButtonInput<Key>;
	public static var X(default, null):ButtonInput<Key>;
	public static var Y(default, null):ButtonInput<Key>;
	public static var Z(default, null):ButtonInput<Key>;
	
	public static var ONE(default, null):ButtonInput<Key>;
	public static var TWO(default, null):ButtonInput<Key>;
	public static var THREE(default, null):ButtonInput<Key>;
	public static var FOUR(default, null):ButtonInput<Key>;
	public static var FIVE(default, null):ButtonInput<Key>;
	public static var SIX(default, null):ButtonInput<Key>;
	public static var SEVEN(default, null):ButtonInput<Key>;
	public static var EIGHT(default, null):ButtonInput<Key>;
	public static var NINE(default, null):ButtonInput<Key>;
	public static var ZERO(default, null):ButtonInput<Key>;
	
	public static var BACKQUOTE(default, null):ButtonInput<Key>;
	
	//
	
	private static var _handle:ButtonInputHandle<Key>;
	
	//
	
	public static inline function checkAnyPressed(buttons:Array<Key>):Bool {
		return _handle.checkAnyPressed(buttons);
	}
	
	public static inline function checkAnyJustPressed(buttons:Array<Key>):Bool {
		return _handle.checkAnyJustPressed(buttons);
	}
	
	public static inline function checkAnyJustReleased(buttons:Array<Key>):Bool {
		return _handle.checkAnyJustReleased(buttons);
	}
	
	public static inline function checkAllPressed(buttons:Array<Key>):Bool {
		return _handle.checkAllPressed(buttons);
	}
	
	public static inline function checkAllJustPressed(buttons:Array<Key>):Bool {
		return _handle.checkAllJustPressed(buttons);
	}
	
	public static inline function checkAllJustReleased(buttons:Array<Key>):Bool {
		return _handle.checkAllJustReleased(buttons);
	}
	
	//
	
	/*
	static inline function khaKeyToKey(key:kha.Key, char:String):Key {
		return Key.createByName(key.getName(), char.length == 0 ? null : [char]);
	}
	*/
	
	static function init():Void {
		kha.input.Keyboard.get().notify(keyDownListener, keyUpListener);
		
		_handle = new ButtonInputHandle<Key>(onStartPressing, onRelease);
		
		ANY 		= _handle.addButton(null);
		
		LEFT 		= _handle.addButton(Key.LEFT);
		RIGHT 		= _handle.addButton(Key.RIGHT);
		UP 			= _handle.addButton(Key.UP);
		DOWN 		= _handle.addButton(Key.DOWN);
		
		ESC 		= _handle.addButton(Key.ESC);
		TAB 		= _handle.addButton(Key.TAB);
		SHIFT 		= _handle.addButton(Key.SHIFT);
		CTRL 		= _handle.addButton(Key.CTRL);
		ALT 		= _handle.addButton(Key.ALT);
		BACKSPACE 	= _handle.addButton(Key.BACKSPACE);
		ENTER 		= _handle.addButton(Key.ENTER);
		DEL 		= _handle.addButton(Key.DEL);
		BACK 		= _handle.addButton(Key.BACK);
		
		SPACE 		= _handle.addButton(Key.CHAR(' '));
		
		A 			= _handle.addButton(Key.CHAR('a'));
		B 			= _handle.addButton(Key.CHAR('b'));
		C 			= _handle.addButton(Key.CHAR('c'));
		D 			= _handle.addButton(Key.CHAR('d'));
		E 			= _handle.addButton(Key.CHAR('e'));
		F 			= _handle.addButton(Key.CHAR('f'));
		G 			= _handle.addButton(Key.CHAR('g'));
		H 			= _handle.addButton(Key.CHAR('h'));
		I 			= _handle.addButton(Key.CHAR('i'));
		J 			= _handle.addButton(Key.CHAR('j'));
		K 			= _handle.addButton(Key.CHAR('k'));
		L 			= _handle.addButton(Key.CHAR('l'));
		M 			= _handle.addButton(Key.CHAR('m'));
		N 			= _handle.addButton(Key.CHAR('n'));
		O 			= _handle.addButton(Key.CHAR('o'));
		P 			= _handle.addButton(Key.CHAR('p'));
		Q 			= _handle.addButton(Key.CHAR('q'));
		R 			= _handle.addButton(Key.CHAR('r'));
		S 			= _handle.addButton(Key.CHAR('s'));
		T 			= _handle.addButton(Key.CHAR('t'));
		U 			= _handle.addButton(Key.CHAR('u'));
		V 			= _handle.addButton(Key.CHAR('v'));
		W 			= _handle.addButton(Key.CHAR('w'));
		X 			= _handle.addButton(Key.CHAR('x'));
		Y 			= _handle.addButton(Key.CHAR('y'));
		Z 			= _handle.addButton(Key.CHAR('z'));
		
		ONE 		= _handle.addButton(Key.CHAR('1'));
		TWO 		= _handle.addButton(Key.CHAR('2'));
		THREE 		= _handle.addButton(Key.CHAR('3'));
		FOUR 		= _handle.addButton(Key.CHAR('4'));
		FIVE 		= _handle.addButton(Key.CHAR('5'));
		SIX 		= _handle.addButton(Key.CHAR('6'));
		SEVEN 		= _handle.addButton(Key.CHAR('7'));
		EIGHT 		= _handle.addButton(Key.CHAR('8'));
		NINE 		= _handle.addButton(Key.CHAR('9'));
		ZERO 		= _handle.addButton(Key.CHAR('0'));
		
		#if js 
		BACKQUOTE 	= _handle.addButton(Key.CHAR('à'));
		#else
		BACKQUOTE 	= _handle.addButton(Key.CHAR('`'));
		#end
	}
	
	static inline function update(elapsed:FastFloat):Void {
		_handle.update(elapsed);
	}
	
	static function keyDownListener(key:kha.Key, char:String):Void {
		switch(key) {
			case kha.Key.LEFT: 			LEFT.waitForRegistration();
			case kha.Key.RIGHT: 		RIGHT.waitForRegistration();
			case kha.Key.UP: 			UP.waitForRegistration();
			case kha.Key.DOWN: 			DOWN.waitForRegistration();

			case kha.Key.ESC:			ESC.waitForRegistration();
			case kha.Key.TAB:			TAB.waitForRegistration();
			case kha.Key.SHIFT:			SHIFT.waitForRegistration();
			case kha.Key.CTRL:			CTRL.waitForRegistration();
			case kha.Key.ALT:			ALT.waitForRegistration();
			case kha.Key.BACKSPACE:		BACKSPACE.waitForRegistration();
			case kha.Key.ENTER:			ENTER.waitForRegistration();
			case kha.Key.DEL:			DEL.waitForRegistration();
			case kha.Key.BACK:			BACK.waitForRegistration();
			
			case kha.Key.CHAR:
				switch(char.toLowerCase()) {
					case ' ':	SPACE.waitForRegistration();
					
					case 'a':	A.waitForRegistration();
					case 'b':	B.waitForRegistration();
					case 'c':	C.waitForRegistration();
					case 'd':	D.waitForRegistration();
					case 'e':	E.waitForRegistration();
					case 'f':	F.waitForRegistration();
					case 'g':	G.waitForRegistration();
					case 'h':	H.waitForRegistration();
					case 'i':	I.waitForRegistration();
					case 'j':	J.waitForRegistration();
					case 'k':	K.waitForRegistration();
					case 'l':	L.waitForRegistration();
					case 'm':	M.waitForRegistration();
					case 'n':	N.waitForRegistration();
					case 'o':	O.waitForRegistration();
					case 'p':	P.waitForRegistration();
					case 'q':	Q.waitForRegistration();
					case 'r':	R.waitForRegistration();
					case 's':	S.waitForRegistration();
					case 't':	T.waitForRegistration();
					case 'u':	U.waitForRegistration();
					case 'v':	V.waitForRegistration();
					case 'w':	W.waitForRegistration();
					case 'x':	X.waitForRegistration();
					case 'y':	Y.waitForRegistration();
					case 'z':	Z.waitForRegistration();
					
					case '1':	ONE.waitForRegistration();
					case '2':	TWO.waitForRegistration();
					case '3':	THREE.waitForRegistration();
					case '4':	FOUR.waitForRegistration();
					case '5':	FIVE.waitForRegistration();
					case '6':	SIX.waitForRegistration();
					case '7':	SEVEN.waitForRegistration();
					case '8':	EIGHT.waitForRegistration();
					case '9':	NINE.waitForRegistration();
					case '0':	ZERO.waitForRegistration();
					
					#if js 
					case 'à':	BACKQUOTE.waitForRegistration();
					#else
					case '`':	BACKQUOTE.waitForRegistration();
					#end
				}
			
			default:
		}
	}
	
	static function keyUpListener(key:kha.Key, char:String):Void {
		switch(key) {
			case kha.Key.LEFT: 			LEFT.waitForReleasing();
			case kha.Key.RIGHT: 		RIGHT.waitForReleasing();
			case kha.Key.UP: 			UP.waitForReleasing();
			case kha.Key.DOWN: 			DOWN.waitForReleasing();

			case kha.Key.ESC:			ESC.waitForReleasing();
			case kha.Key.TAB:			TAB.waitForReleasing();
			case kha.Key.SHIFT:			SHIFT.waitForReleasing();
			case kha.Key.CTRL:			CTRL.waitForReleasing();
			case kha.Key.ALT:			ALT.waitForReleasing();
			case kha.Key.BACKSPACE:		BACKSPACE.waitForReleasing();
			case kha.Key.ENTER:			ENTER.waitForReleasing();
			case kha.Key.DEL:			DEL.waitForReleasing();
			case kha.Key.BACK:			BACK.waitForReleasing();
			
			case kha.Key.CHAR:
				switch(char.toLowerCase()) {
					case ' ':	SPACE.waitForReleasing();
					
					case 'a':	A.waitForReleasing();
					case 'b':	B.waitForReleasing();
					case 'c':	C.waitForReleasing();
					case 'd':	D.waitForReleasing();
					case 'e':	E.waitForReleasing();
					case 'f':	F.waitForReleasing();
					case 'g':	G.waitForReleasing();
					case 'h':	H.waitForReleasing();
					case 'i':	I.waitForReleasing();
					case 'j':	J.waitForReleasing();
					case 'k':	K.waitForReleasing();
					case 'l':	L.waitForReleasing();
					case 'm':	M.waitForReleasing();
					case 'n':	N.waitForReleasing();
					case 'o':	O.waitForReleasing();
					case 'p':	P.waitForReleasing();
					case 'q':	Q.waitForReleasing();
					case 'r':	R.waitForReleasing();
					case 's':	S.waitForReleasing();
					case 't':	T.waitForReleasing();
					case 'u':	U.waitForReleasing();
					case 'v':	V.waitForReleasing();
					case 'w':	W.waitForReleasing();
					case 'x':	X.waitForReleasing();
					case 'y':	Y.waitForReleasing();
					case 'z':	Z.waitForReleasing();
					
					case '1':	ONE.waitForReleasing();
					case '2':	TWO.waitForReleasing();
					case '3':	THREE.waitForReleasing();
					case '4':	FOUR.waitForReleasing();
					case '5':	FIVE.waitForReleasing();
					case '6':	SIX.waitForReleasing();
					case '7':	SEVEN.waitForReleasing();
					case '8':	EIGHT.waitForReleasing();
					case '9':	NINE.waitForReleasing();
					case '0':	ZERO.waitForReleasing();
					
					#if js
					case 'à':	BACKQUOTE.waitForReleasing(); 
					#else
					case '`':	BACKQUOTE.waitForReleasing();
					#end
				}
			
			default:
		}
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

#end