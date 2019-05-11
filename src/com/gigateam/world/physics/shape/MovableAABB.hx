package com.gigateam.world.physics.shape;

/**
 * ...
 * @author Tiger
 */
class MovableAABB extends AABB
{
	public var vx:Float;
	public var vy:Float;
	public var vz:Float;
	public function new(p:Vertex, _width:Float, _vx:Float, _height:Float, _vy:Float, _depth:Float=1, _vz:Float=0) 
	{
		super(p, _width, _height, _depth);
		vx = _vx;
		vy = _vy;
		vz = _vz;
	}
	public function move():Void{
		origin.x += vx;
		origin.y += vy;
		origin.z += vz;
		
		vx = 0;
		vy = 0;
		vz = 0;
	}
	public function getVelocity():Vertex{
		var v:Vertex = new Vertex(vx, vy, vz);
		return v;
	}
	public function setVelocity(v:Vertex):Void{
		vx = v.x;
		vy = v.y;
		vz = v.z;
	}
}