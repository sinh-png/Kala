package kala.system;

#if js

import kha.SystemImpl;

class HTML5 {

	public var mobile(get, never):Bool;

	public function new() {
		
	}
	
	inline function get_mobile():Bool {
		return SystemImpl.mobile;
	}
	
}

#end