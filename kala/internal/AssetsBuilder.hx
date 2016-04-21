package kala.internal;

import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import sys.io.File;

class AssetsBuilder {
	
	public static inline function findResources():String {
		return kha.internal.AssetsBuilder.findResources();
	}

	macro public static function build(type:String):Array<Field> {
		var fields = Context.getBuildFields();
		var path = findResources();
		var content = Json.parse(File.getContent(path + "files.json"));
		var files:Iterable<Dynamic> = content.files;
		
		path = path.substr(0, path.length - 11) + '/';
		
		for (file in files) {
			var name:String = file.name;
			
			switch(type) {
				
				case "sheet":
					var ext = "_ssd";
					
					if (file.type != "blob" || name.lastIndexOf(ext, name.length - ext.length) == -1) continue;
					
					name = name.substr(0, name.length - ext.length);
					content = Json.parse(File.getContent(path + file.files[0]));
					
					fields.push({
						name: name,
						doc: null,
						meta: [],
						access: [APublic],
						kind: FVar(macro :SheetData, macro new SheetData($v{content.frames})),
						pos: Context.currentPos()
					});
					
			}
		}

		return fields;
	}
	
}