package kala;

import haxe.ds.StringMap;
import kala.components.SpriteAnimation;
import kala.math.Rect.RectI;
import kala.objects.Sprite.SpriteData;
import kha.Assets.BlobList;
import kha.Assets.FontList;
import kha.Assets.ImageList;
import kha.Assets.SoundList;
import kha.Assets.VideoList;
import kha.Blob;
import kha.Font;
import kha.Image;
import kha.Sound;
import kha.Video;

@:build(kala.internal.AssetsBuilder.build("sheet"))
class SheetList { public function new() {} }

class SheetData {
	
	private var _frames:StringMap<SpriteData> = new StringMap<SpriteData>();
	
	public function new(framesData:Array<Dynamic>) {
		var frame:SpriteData;
		for (data in framesData) {
			frame = new SpriteData(data.filename, null, [new RectI(data.frame.x, data.frame.y, data.frame.w, data.frame.h)], 0);
			_frames.set(data.filename, frame);
		}
	}
	
	public function get(key:String, ?image:Image):SpriteData {
		if (key.charAt(key.length - 1) == '/' || key.charAt(key.length - 1) == '\\') {
			var spriteData = new SpriteData(key, image, new Array<RectI>(), 0);
			
			var frameKeys = [for (key in _frames.keys()) key];
			frameKeys.sort(function(a, b) {
				    a = a.toLowerCase();
					b = b.toLowerCase();
					
					if (a < b) return -1;
					if (a > b) return 1;
					
					return 0;
			});
		
			for (frameKey in frameKeys) {
				if (frameKey.indexOf(key) == 0) {
					spriteData.frames.push(_frames.get(frameKey).frames[0]);
				}
			}
			
			return spriteData;
		}
		
		return _frames.get(key).clone();
	}
	
}

class Assets {
	
	public static var sheets(default, never):SheetList = new SheetList();
	
	// Below are wrappers for kha.Asset.
	
	public static var images(get, never):ImageList;
	public static var sounds(get, never):SoundList;
	public static var blobs(get, never):BlobList;
	public static var fonts(get, never):FontList;
	public static var videos(get, never):VideoList;
	
	public static var imageFormats(get, never):Array<String>;
	public static var soundFormats(get, never):Array<String>;
	public static var fontFormats(get, never):Array<String>;
	public static var videoFormats(get, never):Array<String>;
	
	public static inline function loadEverything(callback:Void->Void):Void {
		kha.Assets.loadEverything(callback);
	}
		
	//
	
	public static inline function loadImage(name:String, done:Image->Void):Void {
		kha.Assets.loadImage(name, done);
	}
	
	public static inline function loadImageFromPath(path:String, readable:Bool, done:Image->Void):Void {
		kha.Assets.loadImageFromPath(path, readable, done);
	}
	
	//
	
	public static inline function loadBlob(name:String, done:Blob->Void):Void {
		kha.Assets.loadBlob(name, done);
	}
	
	public static inline function loadBlobFromPath(path:String, done:Blob->Void):Void {
		kha.Assets.loadBlobFromPath(path, done);
	}
	
	//
	
	public static inline function loadSound(name:String, done:Sound->Void):Void {
		kha.Assets.loadSound(name, done);
	}
	
	public static inline function loadSoundFromPath(path:String, done:Sound->Void):Void {
		kha.Assets.loadSoundFromPath(path, done);
	}
	
	//
	
	public static inline function loadFont(name:String, done:Font->Void):Void {
		kha.Assets.loadFont(name, done);
	}
	
	public static inline function loadFontFromPath(path:String, done:Font->Void):Void {
		kha.Assets.loadFontFromPath(path, done);
	}
	
	//
	
	public static inline function loadVideo(name:String, done:Video->Void):Void {
		kha.Assets.loadVideo(name, done);
	}
	
	public static inline function loadVideoFromPath(path:String, done:Video->Void):Void {
		kha.Assets.loadVideoFromPath(path, done);
	}
	
	//
	
	static inline function get_images():ImageList {
		return kha.Assets.images;
	}
	
	static inline function get_sounds():SoundList {
		return kha.Assets.sounds;
	}
	
	static inline function get_blobs():BlobList {
		return kha.Assets.blobs;
	}
	
	static inline function get_fonts():FontList {
		return kha.Assets.fonts;
	}
	
	static inline function get_videos():VideoList {
		return kha.Assets.videos;
	}
	
	//
	
	static inline function get_imageFormats():Array<String> {
		return kha.Assets.imageFormats;
	}
	
	static inline function get_soundFormats():Array<String> {
		return kha.Assets.soundFormats;
	}
	
	static inline function get_fontFormats():Array<String> {
		return kha.Assets.fontFormats;
	}
	
	static inline function get_videoFormats():Array<String> {
		return kha.Assets.videoFormats;
	}

}