package com.gigateam.world.physics.algorithm;
import com.gigateam.world.physics.math.Euler;
import com.gigateam.world.physics.shape.Vec;

/**
 * ...
 * @author Tiger
 */
class Equation 
{

	public function new() 
	{
		
	}
	public static function axisDisplacement(velocity:Float, acceleration:Float, deltaTime:Float):Float{
		return velocity * deltaTime + 0.5 * acceleration * Math.pow(deltaTime, 2);
	}
	public static function axisVeolcityAt(velocity:Float, acceleration:Float, deltaTime:Float):Float{
		return velocity + acceleration * deltaTime;
	}
	public static function axisExceedVelTime(force:Float, acceleration:Float, expectedVelocity:Float):Float{
		return (expectedVelocity - force) / acceleration;
	}
	public static function axisExceedPosTime(distance:Float, velocity:Float, acceleration:Float):Float{
		return (-velocity+Math.sqrt(Math.pow(velocity, 2) - (4 * (acceleration/2) *-distance))) / acceleration;
	}
	
	public static function resolveVectorOld(rx:Float, rz:Float, distance:Int, v:Vec):Vec{
		var sinPiRx:Float;
		/*sinPiRx = Math.sin(Math.PI - rx);
		v.z = Std.int(Math.cos(Math.PI - rx)*distance);
		v.y = Std.int(Math.cos(Math.PI - rz)*distance*sinPiRx);
		v.x = Std.int(Math.sin(Math.PI - rz)*distance*sinPiRx);*/
		
		var vz:Float = Math.cos(rx) * distance;
		v.z = Std.int(Math.sin(rx) * distance);
		v.y = Std.int(Math.sin(rz) * vz);
		v.x = Std.int(Math.cos(rz) * vz);
		return v;
	}
	public static function resolveVector(rx:Float, rz:Float, distance:Float, v:Vec):Vec{
		rx = Math.PI - rx;
		rz = Math.PI - rz;
		
		var bx:Float = Math.sin(rz);
		var by:Float = Math.cos(rz);
		var k:Float = Math.sqrt(bx * bx + by * by);
		var z:Float = Math.sin(rx) * k;
		var q:Float = Math.cos(rx) * k;
		
		var ratio:Float = q / k;
		
		var x:Float = bx * ratio;
		var y:Float = by * ratio;
		
		var scale:Float = distance / k;
		
		v.x = x * scale;
		v.y = y * scale;
		v.z = z * scale;
		return v;
	}
	public static function resolveAngle(v1:Vec, v2:Vec, a:Euler):Euler{
		var dx:Float = v2.x - v1.x;
		var dy:Float = v2.y - v1.y;
		var dz:Float = v2.z - v1.z;
		//var magnitude:Float = 180 / Math.PI;
		var magnitude:Float = -1;
		var multiplier:Float = dz > 0 ? 1 : -1;
		//if(dz>0)
		//a.rx = Math.atan2(dz, Math.sqrt(dx * dx + dy * dy));
		//else
		//a.rx = -Math.atan2( -dz, Math.sqrt(dx * dx + dy * dy));
		a.rx = Math.atan2(dz * multiplier, Math.sqrt(dx * dx + dy * dy)) * multiplier;
		//a.ry = 0;
		a.rz = -Math.atan2(dx, dy);
		return a;
	}
	public static function resolveDistance(dx:Float, dy:Float, dz:Float):Float{
		return Math.sqrt(dx * dx + dy * dy + dz * dz);
	}
	public static function resolveDistance2D(dx:Float, dy:Float):Float{
		if (dx == 0 && dy == 0){
			return 0;
		}
		return Math.sqrt(dx * dx + dy * dy);
	}
	public static function slideVector(line:Vec, planeNormal:Vec):Vec{
		//Find the perpenducular axis first
		if (line.dot(planeNormal) > 0){
			return line.clone();
		}
		var axis:Vec = line.cross(planeNormal);
		//We have a right angle plane cross to planeNormal now, then find the axis which perenticular to planeNormal AND in same plane with planeNormal and line.
		axis = axis.cross(planeNormal);
		axis.normalize();
		//Project the length with normalized axis to get magnitude
		var magnitude:Float = axis.dot(line);
		return axis.mul(magnitude);
	}
	/*public static function resolveAngleDisplacement(v1:Vertex, v2:Vertex, a:Angle):Angle{
		var dx:Float = v2.x - v1.x;
		var dy:Float = v2.y - v1.y;
		var dz:Float = v2.z - v1.z;
		//var magnitude:Float = 180 / Math.PI;
		var magnitude:Float = -1;
		a.rx = Math.atan2(dz, dy);
		a.ry = 0;
		a.rz = Math.atan2(dx, dy);
		return a;
	}*/
}