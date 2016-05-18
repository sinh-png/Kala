package kala;

import kha.FastFloat;
import kha.Sound;

@:allow(kala.Kala)
@:allow(kala.AudioChannel)
class Audio {
	
	private static var _channels:Array<AudioChannel> = new Array<AudioChannel>();
	
	public static function play(
		?group:String, sound:Sound, ?volume:FastFloat = 1, loop:Bool = false, kept:Bool = false
	):AudioChannel {
		var channel = new AudioChannel(kha.audio2.Audio1.play(sound, loop), group, kept);
		channel.volume = volume;
		_channels.push(channel);
		
		return channel;
	}
	
	public static function stream(
		?group:String, sound:Sound, ?volume:FastFloat = 1, loop:Bool = false, kept:Bool = false
	):AudioChannel {
		var channel = new AudioChannel(kha.audio2.Audio1.stream(sound, loop), group, kept);
		channel.volume = volume;
		_channels.push(channel);
		
		return channel;
	}
	
	public static function setVolume(?group:String, volume:Float):Void {
		for (channel in _channels) {
			if (channel.group == group) channel.volume = volume;
		}
	}
	
	public static function setMute(?group:String, mute:Bool):Void {
		for (channel in _channels) {
			if (channel.group == group) channel.muted = mute;
		}
	}
	
	public static function toggleMute(?group:String):Void {
		for (channel in _channels) {
			if (channel.group == group) channel.muted = !channel.muted;
		}
	}
	
	public static inline function pause(?group:String):Void {
		for (channel in _channels) {
			if (channel.group == group) channel.pause();
		}
	}
	
	static function update():Void {
		var i = _channels.length;
		while (i-- > 0) {
			if (_channels[i].finished && !_channels[i].kept) {
				_channels.splice(i, 1);
			}
		}
	}
	
}

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