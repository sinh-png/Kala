package kala.audio;

import kha.Sound;

@:access(kala.audio.AudioChannel)
@:allow(kala.audio.AudioChannel)
class AudioGroup {

	public var channels(default, null):Array<AudioChannel>;
	
	public var volume(get, set):Float;
	var _volume:Float;
	
	public var muted(default, set):Bool;
	
	public function new() {
		channels = new Array<AudioChannel>();
		_volume = 1;
	}
	
	public inline function play(sound:Sound, volume:Float = 1, loop:Bool = false, kept:Bool = false):AudioChannel {
		var channel = new AudioChannel(kha.audio2.Audio1.play(sound, loop), this, kept);
		channel._volume = volume;
		channel.channel.volume = muted ? 0 : volume * _volume;
		channels.push(channel);
		return channel;
	}
	
	public inline function stream(group:String, sound:Sound, ?volume:Float = 1, loop:Bool = false, kept:Bool = false):AudioChannel {
		var channel = new AudioChannel(kha.audio2.Audio1.stream(sound, loop), this, kept);
		channel._volume = volume;
		channel.channel.volume = muted ? 0 : volume * _volume;
		channels.push(channel);
		return channel;
	}
	
	inline function update():Void {
		var i = channels.length;
		while (i-- > 0) {
			if (channels[i].finished && !channels[i].kept) {
				channels.splice(i, 1);
			}
		}	
	}
	
	function get_volume():Float {
		return _volume;
	}
	
	function set_volume(value:Float):Float {
		_volume = value;
		for (channel in channels) {
			channel.updateVolume();
		}
		return value;
	}
	
	function set_muted(value:Bool):Bool {
		muted = value;
		for (channel in channels) {
			channel.updateVolume();
		}
		return value;
	}
	
}