package kala.graphics;

import haxe.ds.Vector;
import kala.components.Component;
import kala.math.Color;
import kala.math.Vec2;
import kala.objects.Object;
import kha.Canvas;
import kha.FastFloat;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CubeMap;
import kha.graphics4.FragmentShader;
import kha.graphics4.IndexBuffer;
import kha.graphics4.MipMapFilter;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.TextureFormat;
import kha.graphics4.TextureUnit;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import kha.Image;
import kha.math.FastMatrix4;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.Shaders;
import kha.Video;

@:allow(kala.objects.Object)
@:allow(kala.components.Component)
class Shader {

	public var pipeline:PipelineState;
	
	private var buffer:Image;
	private var g4:kha.graphics4.Graphics;
	private var g2:kha.graphics2.Graphics;

	public function destroy():Void {
		pipeline = null;
		buffer = null;
		g4 = null;
		g2 = null;
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
	
	function update():Void {

	}
	
	function setBuffer(buffer:Image):Void {
		this.buffer = buffer;
		g4 = buffer.g4;
		g2 = buffer.g2;
	}
	
	//
	
	inline function viewport(x:Int, y:Int, width:Int, height:Int):Void {
		g4.viewport(x, y, width, height);
	}
	inline function scissor(x:Int, y:Int, width:Int, height:Int):Void {
		g4.scissor(x, y, width, height);
	}
	
	inline function disableScissor():Void {
		g4.disableScissor();
	}
	
	inline function setVertexBuffer(vertexBuffer:VertexBuffer):Void {
		g4.setVertexBuffer(vertexBuffer);
	}
	
	inline function setVertexBuffers(vertexBuffers:Array<kha.graphics4.VertexBuffer>):Void {
		g4.setVertexBuffers(vertexBuffers);
	}
	
	inline function setIndexBuffer(indexBuffer:IndexBuffer):Void {
		g4.setIndexBuffer(indexBuffer);
	}
	
	inline function setTexture(unit:TextureUnit, texture:Image):Void {
		g4.setTexture(unit, texture);
	}
	
	inline function setVideoTexture(unit:TextureUnit, texture:Video):Void {
		g4.setVideoTexture(unit, texture);
	}
	
	inline function setTextureParameters(
		texunit:TextureUnit, uAddressing:TextureAddressing, vAddressing:TextureAddressing,
		minificationFilter:TextureFilter, magnificationFilter:TextureFilter, mipmapFilter:MipMapFilter
	):Void {
		g4.setTextureParameters(
			texunit, uAddressing, vAddressing, minificationFilter, magnificationFilter, mipmapFilter
		);
	}
	
	inline function createCubeMap(size:Int, format:TextureFormat, usage:Usage , canRead:Bool = false):CubeMap {
		return g4.createCubeMap(size, format, usage, canRead);
	}
	
	inline function renderTargetsInvertedY():Bool {
		return g4.renderTargetsInvertedY();
	}
	
	inline function setBool(location:ConstantLocation, value:Bool):Void {
		g4.setBool(location, value);
	}
	
	inline function setInt(location:ConstantLocation, value:Int):Void {
		g4.setInt(location, value);
	}
	
	inline function setFloat(location:ConstantLocation, value:FastFloat):Void {
		g4.setFloat(location, value);
	}
	
	inline function setFloat2(location:ConstantLocation, value1:FastFloat, value2:FastFloat):Void {
		g4.setFloat2(location, value1, value2);
	}
	
	inline function setFloat3(location:ConstantLocation, value1:FastFloat, value2:FastFloat, value3:FastFloat):Void {
		g4.setFloat3(location, value1, value2, value3);
	}
	
	inline function setFloat4(
		location:ConstantLocation, value1:FastFloat, value2:FastFloat, value3:FastFloat, value4:FastFloat
	):Void {
		g4.setFloat4(location, value1, value2, value3, value4);
	}
	
	inline function setFloats(location:ConstantLocation, floats:Vector<FastFloat>):Void {
		g4.setFloats(location, floats);
	}
	
	inline function setVector2(location:ConstantLocation, value:Vec2):Void {
		g4.setVector2(location, value.toFastVector2());
	}
	
	inline function setVector3(location:ConstantLocation, value:FastVector3):Void {
		g4.setVector3(location, value);
	}
	
	inline function setVector4(location:ConstantLocation, value:FastVector4):Void {
		g4.setVector4(location, value);
	}
	
	inline function setMatrix(location:ConstantLocation, value:FastMatrix4):Void {
		g4.setMatrix(location, value);
	}

}