package kala.asset.sheet;

import kala.math.Rect.RectI;
import kala.objects.sprite.Sprite.SpriteData;
import kha.Image;

class TexturePacker extends SheetData {
	
	public function new(framesData:Array<Dynamic>) {
		super(framesData);
		
		var frame:SpriteData;
		for (data in framesData) {
			frame = new SpriteData(data.filename, null, [new RectI(data.frame.x, data.frame.y, data.frame.w, data.frame.h)], 0);
			_frames.set(data.filename, frame);
		}
	}
	
	override public function get(key:String, ?image:Image):SpriteData {
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
		
		if (spriteData == null) throw 'key "$key" not found. If the sprite data is an animation, remember to add "/" at the end of key.';
		
		spriteData = spriteData.clone();
		spriteData.image = image;
		
		return spriteData;
	}
	
}
