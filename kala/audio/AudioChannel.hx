package kala.audio;

class AudioChannel {
	
	public var channel:kha.audio1.AudioChannel;
	
	public var group:String;
	public var kept:Bool;
	
	public var finished(get, never):Bool;
	public var length(get, never):Float;
	public var position(get, never):Float;
	
	public var volume(get, set):Float;
	var _volume:Float;
	
	public var muted(default, set):Bool;

	public inline function new(channel:kha.audio1.AudioChannel, group:String, kept:Bool) {
		this.channel = channel;
		this.group = group;
		this.kept = kept;
		muted = false;
	}
	
	@:extern
	public inline function play():Void {
		channel.play();
	}
	
	@:extern
	public inline function pause():Void {
		channel.pause();
	}
	
	@:extern
	public inline function stop():Void {
		channel.stop();
		if (!kept) Audio._channels.remove(this);
	}
	
	inline function get_finished():Bool {
		return channel.finished;
	}
	
	inline function get_length():Float {
		return channel.length;
	}
	
	inline function get_position():Float {
		return channel.position;
	}
	
	inline function get_volume():Float {
		return _volume;
	}
	
	inline function set_volume(value:Float):Float {
		if (!muted) channel.volume = value;
		return _volume = value;
	}
	
	inline function set_muted(value:Bool):Bool {
		if (value) channel.volume = 0;
		else channel.volume = _volume;
		
		return muted = value;
	}
	
}