package com.gigateam.world.physics.math;
import com.gigateam.world.physics.shape.Vertex;

/**
 * ...
 * @author Tiger
 */
class Quaternion 
{
	public var x:Float;
	public var y:Float;
	public var z:Float;
	public var w:Float;
	public function new(_x:Float, _y:Float, _z:Float, _w:Float) 
	{
		x = _x;
		y = _y;
		z = _z;
		w = _w;
	}
	public static function fromVertices(from:Vertex, to:Vertex, _w:Float=0):Quaternion{
		var q:Quaternion = new Quaternion(to.x - from.x, to.y - from.y, to.z - from.z, _w);
		q.normalize();
		return q;
	}
	public function normalize():Void{
		var h:Float = Math.sqrt(x * x + y * y + z * z);
		x /= h;
		y /= h;
		z /= h;
	}
}