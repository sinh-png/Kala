package kala;

import haxe.ds.StringMap;
import kala.Assets.AssetLoader;
import kala.components.SpriteAnimation;
import kala.EventHandle.CallbackHandle;
import kala.math.Rect.RectI;
import kala.objects.Sprite.SpriteData;
import kha.Assets.BlobList;
import kha.Assets.FontList;
import kha.Assets.ImageList;
import kha.Assets.SoundList;
import kha.Assets.VideoList;
import kha.Blob;
import kha.FastFloat;
import kha.Font;
import kha.Image;
import kha.Sound;
import kha.Video;

@:build(kala.internal.AssetsBuilder.build("Sheet"))
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
		var spriteData:SpriteData;
		
		if (key.charAt(key.length - 1) == '/' || key.charAt(key.length - 1) == '\\') {
			spriteData = new SpriteData(key, image, new Array<RectI>(), -1);
			
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
		
		spriteData = _frames.get(key);
		
		if (spriteData == null) throw "key not found";
		
		spriteData = spriteData.clone();
		spriteData.image = image;
		
		return spriteData;
	}
	
}

@:build(kala.internal.AssetsBuilder.build("FileArray"))
class Assets {
	
	public static var loader(default, never):AssetLoader = new AssetLoader();
	
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

@:access(kala.CallbackHandle)
class AssetLoader extends EventHandle {
	
	public var queuingAssets(get, never):Array<AssetLoadingInfo>;
	var _queuingAssets:Array<AssetLoadingInfo> = new Array<AssetLoadingInfo>();
	
	public var loadedAssets(get, never):Array<AssetLoadingInfo>;
	var _loadedAssets:Array<AssetLoadingInfo> = new Array<AssetLoadingInfo>();
	
	public var loading(get, never):Bool;
	public var paused(get, null):Bool;
	
	/**
	 * The loading process in percent, between 0 and 1.
	 */
	public var percent(default, null):FastFloat = 0;
	public var totalSize(default, null):FastFloat = 0;
	public var loadedSize(default, null):FastFloat = 0;
	
	public var onProcess(default, null):CallbackHandle<Dynamic->AssetLoadingInfo->AssetLoadingInfo->Bool>;
	
	/* 
	 * 0 - no action
	 * 1 - loading
	 * 2 - loading & waiting to stop
	 * 3 - loading & waiting to pause
	 * 4 - paused
	 */
	private var _state:Int = 0; 
	
	public function new() {
		super();
		onProcess = addCBHandle(new CallbackHandle<Dynamic->AssetLoadingInfo->AssetLoadingInfo->Bool>());
	}
	
	/**
	 * Queue an asset for loading. 
	 * 
	 * @param	type		Type of the asset.
	 * @param	nameOrPath	Name or path of the asset to be loaded. Taken as path if start with an '>' character or if asPath is set to true.
	 * @param	size		Size of the asset, used to calculate the percent of loading process.
	 * @param	asPath		If set to true, nameOrPath is taken as path otherwise as name.
	 * @param	readable	If the asset is an image and is loaded from path, this will determine if the image is readable or not.
	 * 
	 * @return				This loader.
	 */
	public function queue(type:AssetType, nameOrPath:String, ?size:FastFloat = 1, asPath:Bool = false, readable:Bool = true):AssetLoader {
		if (_state != 0) throw "Can't queue new asset while loading or paused.";
		
		totalSize += size < 1 ? 1 : size;
		
		var asset:AssetLoadingInfo;
		
		if (asPath || nameOrPath.charAt(0) == '>') {
			asset = new AssetLoadingInfo(type, null, nameOrPath, size, readable);
		} else {
			asset = new AssetLoadingInfo(type, nameOrPath, null, size);
		}
		
		_queuingAssets.push(asset);
	
		return this;
	}
	
	public inline function queueImage(nameOrPath:String, ?size:FastFloat = 1, asPath:Bool = false, readable:Bool = true):AssetLoader {
		return queue(IMAGE, nameOrPath, size, asPath, readable);
	}
	
	public inline function queueSound(nameOrPath:String, ?size:FastFloat = 1, asPath:Bool = false):AssetLoader {
		return queue(SOUND, nameOrPath, size, asPath);
	}
	
	public inline function queueFont(nameOrPath:String, ?size:FastFloat = 1, asPath:Bool = false):AssetLoader {
		return queue(FONT, nameOrPath, size, asPath);
	}
	
	public inline function queueVideo(nameOrPath:String, ?size:FastFloat = 1, asPath:Bool = false):AssetLoader {
		return queue(VIDEO, nameOrPath, size, asPath);
	}
	
	public inline function queueBlob(nameOrPath:String, ?size:FastFloat = 1, asPath:Bool = false):AssetLoader {
		return queue(BLOB, nameOrPath, size, asPath);
	}
	
	/**
	 * Queue all assets that were processed by Khamake except for shaders and assets which are already in the queuing list.
	 * 
	 * @return	This loader.
	 */
	public function queueAll(?sizes:Array<FastFloat>):AssetLoader {
		var i = 0;
		var type:AssetType;
		for (file in Assets.files) {
			if (file.type != "shader") {
				type = AssetType.createByName(cast(file.type, String).toUpperCase());
				if (findQueuingAssetByName(type, file.name) == -1) {
					queue(type, file.name, sizes == null ? 1 : sizes[i]);
				}
			}

			i++;
		}
		
		return this;
	}
	
	public inline function bunble(assets:Array<AssetLoadingInfo>):AssetLoader {
		for (asset in assets) {
			_queuingAssets.push(asset);
			totalSize += asset.size;
		}
		
		return this;
	}
	
	public function load(?onProcessCallback:Dynamic->AssetLoadingInfo->AssetLoadingInfo->Bool):AssetLoadingInfo {
		if (_queuingAssets.length > 0 && (_state == 0 || _state == 4)) {
			if (onProcessCallback != null) onProcess.notify(onProcessCallback);
			
			process(null);
			_state = 1;
			
			return _queuingAssets[0];
		}
		
		return null;
	}
	
	public function reload():AssetLoadingInfo {
		if ((_queuingAssets.length > 0 || _loadedAssets.length > 0) && (_state == 0 || _state == 4)) {
			loadedSize = percent = 0;
		
			while (_loadedAssets.length > 0) {
				_queuingAssets.push(_loadedAssets.splice(0, 1)[0]);
			}
			
			process(null);
			_state = 1;
			
			return _queuingAssets[0];
		}
		
		return null;
	}
	
	public inline function cancel():AssetLoader {
		_state = 2;
		return this;
	}
	
	public inline function pause():Void {
		_state = 3;
	}
	
	function process(data:Dynamic):Void {
		var loadedAsset:AssetLoadingInfo = null;
		
		if (data != null) {
			loadedAsset = _queuingAssets.splice(0, 1)[0];
			_loadedAssets.push(loadedAsset);
			loadedSize += loadedAsset.size;
			percent = loadedSize / totalSize;
		}
		
		var nextAsset = _queuingAssets.length > 0 ? _queuingAssets[0] : null;
		
		var i = 0;
		var callback:Dynamic->AssetLoadingInfo->AssetLoadingInfo->Bool;
		while (i < onProcess.lenght) {
			callback = onProcess._callbacks[i].cbFunction;
			if (callback(data, loadedAsset, nextAsset)) {
				onProcess._callbacks.splice(i, 1);
			} else i++;
		}
		
		if (nextAsset == null) { // all assets loaded
			_state = 0;
		} else {
			if (_state == 2) { // cancelled
				_queuingAssets.splice(0, _queuingAssets.length);
				_loadedAssets.splice(0, _loadedAssets.length);
				nextAsset = null;
				_state = 0;
				loadedSize = totalSize = percent = 0;
			} else if (_state == 3) { // paused
				nextAsset = null;
				_state = 4;
			} else {
				nextAsset.load(process);
			}
		}
	}
	
	function findQueuingAssetByName(type:AssetType, name:String):Int {
		for (i in 0..._queuingAssets.length) {
			if (_queuingAssets[i].type.getIndex() == type.getIndex() && _queuingAssets[i].name == name) {
				return i;
			}
		}
		
		return -1;
	}

	inline function get_loading():Bool {
		return _state > 0 && _state != 4;
	}
	
	inline function get_paused():Bool {
		return _state == 4;
	}

	inline function get_queuingAssets():Array<AssetLoadingInfo> {
		return _queuingAssets.copy();
	}
	
	inline function get_loadedAssets():Array<AssetLoadingInfo> {
		return _loadedAssets.copy();
	}
	
}

class AssetLoadingInfo {
	
	public var name:String;
	public var path:String;
	public var size:FastFloat;
	public var type:AssetType;
	public var readable:Bool;
	
	public inline function new(type:AssetType, name:String, ?path:String, ?size:FastFloat = 1, readable:Bool = true) {
		this.type = type;
		this.name = name;
		this.path = path;
		this.size = size;
		this.readable = readable;
	}
	
	@:extern
	public inline function load(callback:Dynamic->Void):Void {
		if (name == null) {
			if (path == null) return;
			
			switch(type) {
				case IMAGE: Assets.loadImageFromPath(path, readable, callback);
				case SOUND: Assets.loadSoundFromPath(path, callback);
				case FONT: 	Assets.loadFontFromPath(path, callback);
				case VIDEO: Assets.loadVideoFromPath(path, callback);
				case BLOB: 	Assets.loadBlobFromPath(path, callback);
			}
		} else {
			switch(type) {
				case IMAGE: Assets.loadImage(name, callback);
				case SOUND: Assets.loadSound(name, callback);
				case FONT: 	Assets.loadFont(name, callback);
				case VIDEO: Assets.loadVideo(name, callback);
				case BLOB: 	Assets.loadBlob(name, callback);
			}
		}
	}
	
}

enum AssetType {
	
	IMAGE;
	SOUND;
	FONT;
	VIDEO;
	BLOB;
	
}