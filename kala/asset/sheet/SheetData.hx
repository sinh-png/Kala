package kala.asset.sheet;

import haxe.ds.StringMap;
import kala.objects.sprite.Sprite.SpriteData;
import kha.Image;

class SheetData {

	private var _frames:StringMap<SpriteData> = new StringMap<SpriteData>();
	
	public function new(framesData:Array<Dynamic>) {
		
	}
	
	public function get(key:String, ?image:Image):SpriteData {
		return null;
	}
	
}