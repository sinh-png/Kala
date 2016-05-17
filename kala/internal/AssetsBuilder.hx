package kala.internal;

import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import sys.io.File;

class AssetsBuilder {
	
	public static var resPath(default, null):String;
	public static var resJson(default, null):Dynamic;
	public static var files(default, null):Array<Dynamic>;
	
	public static inline function findResources():String {
		return kha.internal.AssetsBuilder.findResources();
	}

	macro public static function build(type:String):Array<Field> {
		var fields = Context.getBuildFields();
		
		if (resPath == null) {
			resPath = findResources();
			resJson = Json.parse(File.getContent(resPath + "files.json"));
			files = resJson.files;
		}

		var path = resPath.substr(0, resPath.length - 11) + '/';
		
		switch(type) {
			
			case "FileArray":
				fields.push({
					name: "files",
					doc: "The info of the files listed in files.json.",
					meta: [],
					access: [APublic, AStatic],
					kind: FProp("default", "never", macro :Array<Dynamic>, macro $v{files}),
					pos: Context.currentPos()
				});
			
			case "Sheet":
				var json:Dynamic;
				
				for (file in files) {
					var name:String = file.name;
					
					var ext = "_ssd";
				
					if (file.type != "blob" || name.lastIndexOf(ext, name.length - ext.length) == -1) continue;
					
					name = name.substr(0, name.length - ext.length);
					json = Json.parse(File.getContent(path + file.files[0]));
					
					fields.push({
						name: name,
						doc: null,
						meta: [],
						access: [APublic, AStatic],
						kind: FProp("default", "never", macro :SheetData, macro new SheetData($v{json.frames})),
						pos: Context.currentPos()
					});
				}
		}

		return fields;
	}
	
}