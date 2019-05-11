package com.gigateam.world.physics.shape;
import com.gigateam.world.physics.algorithm.ProjectionResult;

/**
 * ...
 * @author Tiger
 */
class Convex extends AABB{
{
	private var _normalizedAngles:Array<Float>;
	private var _normalizedRadians:Array<Float>;
	
	private var _renderingVertices:Array<Vec>;
	private var _renderingAxis:Array<Vec>;
	
	private var _rotation:Float = 0;
	private var _axis:Int;
	private var _vertices:Array<Vec>;
	public function new(p:Vec, vertices:Array<Vec>, facingAxis:Int) 
	{
		super(p, 0, 0, 0);
		_vertices = [];
		_normalizedAngles = [];
		_normalizedRadians = [];
		
		_renderingVertices = [];
		_renderingAxis = [];
		
		_axis = facingAxis;
		var vertex:Vec;
		for (v in vertices){
			vertex = v;
			_vertices.push(new Vec(vertex.x, vertex.y, vertex.z));
			_renderingVertices.push(new Vec(vertex.x, vertex.y, vertex.z));
			
			_renderingAxis.push(new Vec(0, 0, 0));
			
			var dx:Float = vertex.x;
			var dy:Float = vertex.y;
			
			var radian:Float = Math.sqrt(dx * dx + dy * dy);
			var rot:Float = Math.atan2(dy, dx);
			
			_normalizedAngles.push(rot);
			_normalizedRadians.push(radian);
		}
	}
	public function setRotation(r:Float):Bool{
		if (_rotation == r){
			return false;
		}
		_rotation = r;
		
		updateRotation();
		return true;
	}
	public function normalAt(index:Int, v:Vec):Vec{
		var from:Vec = _renderingVertices[index];
		var to:Vec;
		var toIndex:Int = index + 1;
		if (toIndex > _renderingVertices.length){
			return null;
		}else if (toIndex == _renderingVertices.length){
			to = _renderingVertices[0];
		}else{
			to = _renderingVertices[toIndex];
		}
		
		var dx:Float = to.x - from.x;
		var dy:Float = to.y - from.y;
		
		var angle:Float = Math.atan2(dy, dx);
		var radian:Float = Math.sqrt(dx * dx + dy * dy);
		
		angle+= Math.PI * 0.5;
		
		v.y = Math.sin(angle) * radian;
		v.x = Math.cos(angle) * radian;
		return p;
	}
	public function project(axis:Vec, projectionResult:ProjectionResult):Void{
		
	}
	private function updateRotation():Void{
		var i:Int = 0;
		var p:Point;
		var angle:Float = _rotation;
		var rot:Float;
		var radian:Float;
		
		for (v in _renderingVertices.length){
			var p:Vec = v;
			
			radian = _normalizedRadians[i];
			rot = _normalizedAngles[i] + angle;
			p.y = Math.sin(rot) * radian;
			p.x = Math.cos(rot) * radian;
			i++;
		}
		i = 0;
		for (v in _renderingVertices.length){
			normalAt(i, _renderingAxis[i]);
			i++;
		}
	}
	public function getRotation():Float{
		return _rotation;
	}
}