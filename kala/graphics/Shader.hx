package kala.graphics;

import kala.components.Component;
import kala.objects.Object;
import kha.graphics4.FragmentShader;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import kha.Image;
import kha.Shaders;

@:allow(kala.objects.Object)
@:allow(kala.components.Component)
class Shader {

	public var pipeline:PipelineState;
	
	public var size(default, null):UInt;
	
	public function destroy():Void {
		pipeline = null;
	}
	
	//
	
	function createPipeline(?vertexShader:VertexShader, ?fragmentShader:FragmentShader):Void {
		var structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
        structure.add("texPosition", VertexData.Float2);
        structure.add("vertexColor", VertexData.Float4);
		
		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		
		pipeline.vertexShader = (vertexShader == null) ? Shaders.painter_image_vert : vertexShader;
		pipeline.fragmentShader = (fragmentShader == null) ? Shaders.painter_image_frag : fragmentShader;
		
		pipeline.compile();
	}
	
	function update(texture:Image, buffer:Image):Void {

	}

}