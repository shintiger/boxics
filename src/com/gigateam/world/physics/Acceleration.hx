package com.gigateam.world.physics;
import com.gigateam.world.physics.shape.Vertex;


/**
 * ...
 * @author Tiger
 */
class Acceleration
{
	public var accelerationX:Float = 0;
	public var accelerationY:Float = 0;
	public var accelerationZ:Float = 0;
	public var maxVelX:Float = 0;
	public var maxVelY:Float = 0;
	public var maxVelZ:Float = 0;
	public function new(ax:Float=0, ay:Float=0, az:Float=0) 
	{
		accelerationX = ax;
		accelerationY = ay;
		accelerationZ = az;
	}
	public function setAccel(v:Vertex):Void{
		accelerationX = v.x;
		accelerationY = v.y;
		accelerationZ = v.z;
	}
	public function setMaxVel(v:Vertex):Void{
		maxVelX = v.x;
		maxVelY = v.y;
		maxVelZ = v.z;
	}
	public function getAccel(out:Vertex=null):Vertex{
		if (out == null){
			out = new Vertex();
		}
		out.x = accelerationX;
		out.y = accelerationY;
		out.z = accelerationZ;
		return out;
	}
	public function getMaxVel(out:Vertex=null):Vertex{
		if (out == null){
			out = new Vertex();
		}
		out.x = maxVelX;
		out.y = maxVelY;
		out.z = maxVelZ;
		return out;
	}
	public static function create(fx:Float, ax:Float, fy:Float, ay:Float, fz:Float=0, az:Float=0):Acceleration{
		return new Acceleration(ax, ay, az);
	}
	public function cloneFrom(accel:Acceleration):Void{
		accelerationX = accel.accelerationX;
		accelerationY = accel.accelerationY;
		accelerationZ = accel.accelerationZ;
		maxVelX = accel.maxVelX;
		maxVelY = accel.maxVelY;
		maxVelZ = accel.maxVelZ;
	}
	public function clone():Acceleration{
		var acc:Acceleration = new Acceleration();
		acc.cloneFrom(this);
		return acc;
	}
	public function blend(accel:Acceleration):Void{
		accelerationX += accel.accelerationX;
		accelerationY += accel.accelerationY;
		accelerationZ += accel.accelerationZ;
		
		if (accelerationX == 0){
			maxVelX = 0;
		}else if (accelerationX > 0){
			maxVelX = Math.max(maxVelX, accel.maxVelX);
		}else{
			maxVelX = Math.min(maxVelX, accel.maxVelX);
		}
		
		if (accelerationY == 0){
			maxVelY = 0;
		}else if (accelerationY > 0){
			maxVelY = Math.max(maxVelY, accel.maxVelY);
		}else{
			maxVelY = Math.min(maxVelY, accel.maxVelY);
		}
		
		if (accelerationZ == 0){
			maxVelZ = 0;
		}else if (accelerationY > 0){
			maxVelZ = Math.max(maxVelZ, accel.maxVelZ);
		}else{
			maxVelZ = Math.min(maxVelZ, accel.maxVelZ);
		}
	}
}