package kala.internal;

import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import sys.io.File;

class AssetsBuilder {
	
	public static inline function findResources():String {
		return kha.internal.AssetsBuilder.findResources();
	}

	macro public static function buildSheets():Array<Field> {
		var fields = Context.getBuildFields();
		var path = findResources();
		var content = Json.parse(File.getContent(path + "files.json"));
		var files:Iterable<Dynamic> = content.files;
		
		for (file in files) {
			var name:String = file.name;
			if (file.type != "blob" || name.lastIndexOf("_sheet", name.length - 6) == -1) continue;
			
			name = name.substr(0, name.length - 6);
			path = path.substr(0, path.length - 11) + '/';
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

		return fields;
	}
	
}