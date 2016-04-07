package kala.components.graphics;

import haxe.ds.Vector;
import kala.components.Component;
import kala.math.Color;
import kala.math.Vec2;
import kala.objects.Object;
import kha.Canvas;
import kha.FastFloat;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CubeMap;
import kha.graphics4.Graphics;
import kha.graphics4.IndexBuffer;
import kha.graphics4.MipMapFilter;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.TextureFormat;
import kha.graphics4.TextureUnit;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.Image;
import kha.math.FastMatrix4;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.Video;


class Blender extends Component<Object> {

	public var pipeline:PipelineState;
	
	private var _graphics:Graphics;
	
	override public function addTo(object:Object):Blender {
		super.addTo(object);
		
		object.onPreDraw.addComponentCB(this, preDraw);
		object.onPostDraw.addComponentCB(this, postDraw);
		
		return this;
	}
	
	override public function remove():Void {
		if (object != null) {
			object.onPreDraw.removeComponentCB(this, preDraw);
			object.onPostDraw.removeComponentCB(this, postDraw);	
		}
		
		super.remove();
	}
	
	override public function destroy():Void {
		super.destroy();
		pipeline = null;
		_graphics = null;
	}
	
	//
	
	public function applyPipeline(canvas:Canvas):Void {
		canvas.g2.pipeline = pipeline;
	}
	
	public function preDraw(obj:Object, data:DrawingData, canvas:Canvas):Bool {
		_graphics = canvas.g4;
		if (pipeline != null && canvas.g2.pipeline != pipeline) applyPipeline(canvas);
		return false;
	}
	
	public function postDraw(obj:Object, data:DrawingData, canvas:Canvas):Void {
		
	}
	
	//
	
	public inline function begin(additionalRenderTargets:Array<Canvas> = null):Void {
		_graphics.begin(additionalRenderTargets);
	}
	
	public inline function end():Void {
		_graphics.end();
	}
	
	public inline function vsynced():Bool {
		return _graphics.vsynced();
	}
	
	public inline function refreshRate():Int {
		return _graphics.refreshRate();
	}
	
	public inline function clear(?color:Color, ?depth:Float, ?stencil:Int):Void {
		return _graphics.clear(color.argb(), depth, stencil);
	}

	public inline function viewport(x:Int, y:Int, width:Int, height:Int):Void {
		_graphics.viewport(x, y, width, height);
	}
	public inline function scissor(x:Int, y:Int, width:Int, height:Int):Void {
		_graphics.scissor(x, y, width, height);
	}
	
	public inline function disableScissor():Void {
		_graphics.disableScissor();
	}
	
	public inline function setVertexBuffer(vertexBuffer:VertexBuffer):Void {
		_graphics.setVertexBuffer(vertexBuffer);
	}
	
	public inline function setVertexBuffers(vertexBuffers:Array<kha.graphics4.VertexBuffer>):Void {
		_graphics.setVertexBuffers(vertexBuffers);
	}
	
	public inline function setIndexBuffer(indexBuffer:IndexBuffer):Void {
		_graphics.setIndexBuffer(indexBuffer);
	}
	
	public inline function setTexture(unit:TextureUnit, texture:Image):Void {
		_graphics.setTexture(unit, texture);
	}
	
	public inline function setVideoTexture(unit:TextureUnit, texture:Video):Void {
		_graphics.setVideoTexture(unit, texture);
	}
	
	public inline function setTextureParameters(
		texunit:TextureUnit, uAddressing:TextureAddressing, vAddressing:TextureAddressing,
		minificationFilter:TextureFilter, magnificationFilter:TextureFilter, mipmapFilter:MipMapFilter
	):Void {
		_graphics.setTextureParameters(
			texunit, uAddressing, vAddressing, minificationFilter, magnificationFilter, mipmapFilter
		);
	}
	
	public inline function createCubeMap(size:Int, format:TextureFormat, usage:Usage , canRead:Bool = false):CubeMap {
		return _graphics.createCubeMap(size, format, usage, canRead);
	}
	
	public inline function renderTargetsInvertedY():Bool {
		return _graphics.renderTargetsInvertedY();
	}
	
	public inline function instancedRenderingAvailable():Bool {
		return _graphics.instancedRenderingAvailable();
	}
	
	public inline function setBool(location:ConstantLocation, value:Bool):Void {
		_graphics.setBool(location, value);
	}
	
	public inline function setInt(location:ConstantLocation, value:Int):Void {
		_graphics.setInt(location, value);
	}
	
	public inline function setFloat(location:ConstantLocation, value:FastFloat):Void {
		_graphics.setFloat(location, value);
	}
	
	public inline function setFloat2(location:ConstantLocation, value1:FastFloat, value2:FastFloat):Void {
		_graphics.setFloat2(location, value1, value2);
	}
	
	public inline function setFloat3(location:ConstantLocation, value1:FastFloat, value2:FastFloat, value3:FastFloat):Void {
		_graphics.setFloat3(location, value1, value2, value3);
	}
	
	public inline function setFloat4(
		location:ConstantLocation, value1:FastFloat, value2:FastFloat, value3:FastFloat, value4:FastFloat
	):Void {
		_graphics.setFloat4(location, value1, value2, value3, value4);
	}
	
	public inline function setFloats(location:ConstantLocation, floats:Vector<FastFloat>):Void {
		_graphics.setFloats(location, floats);
	}
	
	public inline function setVector2(location:ConstantLocation, value:Vec2):Void {
		_graphics.setVector2(location, value.toFastVector2());
	}
	
	public inline function setVector3(location:ConstantLocation, value:FastVector3):Void {
		_graphics.setVector3(location, value);
	}
	
	public inline function setVector4(location:ConstantLocation, value:FastVector4):Void {
		_graphics.setVector4(location, value);
	}
	
	public inline function setMatrix(location:ConstantLocation, value:FastMatrix4):Void {
		_graphics.setMatrix(location, value);
	}
	
	public inline function drawIndexedVertices(start:Int = 0, count:Int = -1):Void {
		_graphics.drawIndexedVertices(start, count);
	}
	
	public inline function drawIndexedVerticesInstanced(instanceCount:Int, start:Int = 0, count:Int = -1):Void {
		_graphics.drawIndexedVerticesInstanced(instanceCount, start, count);
	}
	
	public inline function flush():Void {
		_graphics.flush();
	}

}