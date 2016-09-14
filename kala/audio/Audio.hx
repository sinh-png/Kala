package kala.audio;

import kha.Sound;

@:allow(kala.Kala)
@:allow(kala.audio.AudioChannel)
class Audio {
	
	public static var groups(default, null):Array<AudioGroup> = new Array<AudioGroup>();
	
	public static function play(sound:Sound, volume:Float = 1, loop:Bool = false):AudioChannel {
		var channel = new AudioChannel(kha.audio2.Audio1.play(sound, loop), null, false);
		channel.volume = volume;
		return channel;
	}
	
	public static function stream(sound:Sound, volume:Float = 1, loop:Bool = false):AudioChannel {
		var channel = new AudioChannel(kha.audio2.Audio1.stream(sound, loop), null, false);
		channel.volume = volume;
		return channel;
	}
	
	static function update():Void {
		for (group in groups) {
			var channels = group.channels;
			var i = channels.length;
			while (i-- > 0) {
				if (channels[i].finished && !channels[i].kept) {
					channels.splice(i, 1);
				}
			}
		}
	}
	
}