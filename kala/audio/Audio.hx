package kala.audio;

import kha.FastFloat;
import kha.Sound;

@:allow(kala.Kala)
@:allow(kala.audio.AudioChannel)
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