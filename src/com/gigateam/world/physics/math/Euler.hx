package com.gigateam.world.physics.math;
import com.gigateam.world.physics.algorithm.Equation;
import com.gigateam.world.physics.shape.Vec;

/**
 * ...
 * @author Tiger
 */
class Euler 
{
	public var rx:Float;
	public var rz:Float;
	public function new() 
	{
		
	}
	public static function fromVertices(from:Vec, to:Vec):Euler{
		var e:Euler = new Euler();
		Equation.resolveAngle(from, to, e);
		return e;
	}
	public static function fromAngle(rotationX:Float, rotationZ:Float):Euler{
		var e:Euler = new Euler();
		e.rx = rotationX;
		e.rz = rotationZ;
		return e;
	}
	public function toDirection(distance:Int, out:Vec):Vec{
		if (out == null){
			out = new Vec(0, 0);
		}
		Equation.resolveVector(rx, rz, distance, out);
		return out;
	}
}