package com.gigateam.world.physics.algorithm;
import com.gigateam.world.physics.shape.AABB;
import com.gigateam.world.physics.shape.MovableAABB;
import com.gigateam.world.physics.shape.Vertex;

/**
 * ...
 * @author Tiger
 * 
 * Hints:Normal's direction is reverse of moving direction
 * Example: x is moving -5 this step, collision found on X axis, normalX must be 1
 */
class Collision 
{
	public static inline var ENTRY_MAX:Int = 65535000;
	private static var broadphase:AABB;
	public function new() 
	{
		
	}
	public static function AABBCheck(b1:AABB, b2:AABB):Bool{
		return !((b1.origin.x + b1.w) < b2.origin.x || b1.origin.x > (b2.origin.x + b2.w) || (b1.origin.y + b1.h) < b2.origin.y || b1.origin.y > (b2.origin.y + b2.h) || (b1.origin.z + b1.d) < b2.origin.z || b1.origin.z > (b2.origin.z + b2.d));
	}
	//M of minM means moving one; S of minS means stationary;
	public static function timeOfImpact(minM:Float, maxM:Float, minS:Float, maxS:Float, velocityM:Float, result:Array<Float> = null):Bool{
		var invEntry:Float;
		var invExit:Float;
		var entry:Float;
		var exit:Float;
		
		var d1:Float = minS - maxM;
		var d2:Float = maxS - minM;
		if (velocityM > 0){
			invEntry = d1;
			invExit = d2;
		}else{
			invEntry = d2;
			invExit = d1;
		}
		// find time of collision and time of leaving for each axis (if statement is to prevent divide by zero)
		if (velocityM == 0)
		{
			entry = -ENTRY_MAX;
			exit = ENTRY_MAX;
		}
		else
		{
			entry = invEntry / velocityM;
			exit = invExit / velocityM;
		}
		result[0] = entry;
		result[1] = exit;
		result[3] = invEntry;
		result[4] = invExit;
		//Entry over 1 means at the end of this travel still not touching; Entry greater than Exit means moving apart
		if (entry > 1 || entry > exit){
			return false;
		}
		
		return true;
	}
	public static function sweepAABB(b1:MovableAABB, b2:AABB, result:SweepTestResult):Bool{
		var nums:Array<Float> = [0, 0, 0, 0];
		
		timeOfImpact(b1.origin.x, b1.origin.x + b1.w, b2.origin.x, b2.origin.x + b2.w, b1.vx, nums);
		var xEntry:Float = nums[0];
		var xExit:Float = nums[1];
		var xInvEntry:Float = nums[2];
		var xInvExit:Float = nums[3];
		
		timeOfImpact(b1.origin.y, b1.origin.y + b1.h, b2.origin.y, b2.origin.y + b2.h, b1.vy, nums);
		var yEntry:Float = nums[0];
		var yExit:Float = nums[1];
		var yInvEntry:Float = nums[2];
		var yInvExit:Float = nums[3];
		
		timeOfImpact(b1.origin.z, b1.origin.z + b1.d, b2.origin.z, b2.origin.z + b2.d, b1.vz, nums);
		var zEntry:Float = nums[0];
		var zExit:Float = nums[1];
		var zInvEntry:Float = nums[2];
		var zInvExit:Float = nums[3];
		
		result.target = b2;
		result.entryTime = Math.max(Math.max(xEntry, yEntry), zEntry);
		var exitTime:Float = Math.min(Math.min(xExit, yExit), zExit);
		
		// if there was no collision
		if (result.entryTime > exitTime || xEntry < 0 && yEntry < 0 && zEntry < 0 || xEntry > 1 || yEntry > 1 || zEntry > 1)
		{
			result.affectingAxis = new Vertex();
			result.normalX = 0;
			result.normalY = 0;
			result.normalZ = 0;
			result.entryTime = 1;
			result.isCollided = false;
			return false;
		}
		else // if there was a collision
		{        		
			// calculate normal of collided surface
			result.normalX = 0;
			result.normalY = 0;
			result.normalZ = 0;
			var sign:Float = 1;
			if (result.entryTime==xEntry)
			{
				result.normalX = getNormal(xInvEntry, b1.origin.x, b2.origin.x);
				result.affectingAxis = new Vertex(result.normalX * sign, 0, 0);
			}
			else if(result.entryTime==yEntry)
			{
				result.normalY = getNormal(yInvEntry, b1.origin.y, b2.origin.y);
				result.affectingAxis = new Vertex(0, result.normalY * sign, 0);
			}else
			{
				result.normalZ = getNormal(zInvEntry, b1.origin.z, b2.origin.z);
				result.affectingAxis = new Vertex(0, 0, result.normalZ * sign);
			}
			// return the time of collision
			
		}
		result.isCollided =  true;
		return true;
	}
	public static function sweptAABB(b1:MovableAABB, b2:AABB, cr:SweepTestResult):Bool{
		var ratio:Int = cr.ratio;
		var xInvEntry:Float;
		var yInvEntry:Float;
		var xInvExit:Float;
		var yInvExit:Float;
		var zInvEntry:Float;
		var zInvExit:Float;

		// find the distance between the objects on the near and far sides for both x and y
		if (b1.vx > 0)
		{
			//xInvEntry will be NEGATIVE if collide
			xInvEntry = b2.origin.x - (b1.origin.x + b1.w);
			xInvExit = (b2.origin.x + b2.w) - b1.origin.x;
		}
		else 
		{
			//xInvEntry will be POSITIVE if collide
			xInvEntry = (b2.origin.x + b2.w) - b1.origin.x;
			xInvExit = b2.origin.x - (b1.origin.x + b1.w);
		}
		

		if (b1.vy > 0)
		{
			yInvEntry = b2.origin.y - (b1.origin.y + b1.h);
			yInvExit = (b2.origin.y + b2.h) - b1.origin.y;
		}
		else
		{
			yInvEntry = (b2.origin.y + b2.h) - b1.origin.y;
			yInvExit = b2.origin.y - (b1.origin.y + b1.h);
		}
		
		if (b1.vz > 0)
		{
			zInvEntry = b2.origin.z - (b1.origin.z + b1.d);
			zInvExit = (b2.origin.z + b2.d) - b1.origin.z;
		}
		else
		{
			zInvEntry = (b2.origin.z + b2.d) - b1.origin.z;
			zInvExit = b2.origin.z - (b1.origin.z + b1.d);
		}
		
		// find time of collision and time of leaving for each axis (if statement is to prevent divide by zero)
		var xEntry:Float;
		var yEntry:Float;
		var xExit:Float;
		var yExit:Float;
		var zEntry:Float;
		var zExit:Float;
		
		if (b1.vx == 0)
		{
			xEntry = -ENTRY_MAX;
			xExit = ENTRY_MAX;
		}
		else
		{
			xEntry = xInvEntry / b1.vx * ratio;
			xExit = xInvExit / b1.vx * ratio;
		}

		if (b1.vy == 0)
		{
			yEntry = -ENTRY_MAX;
			yExit = ENTRY_MAX;
		}
		else
		{
			yEntry = yInvEntry / b1.vy * ratio;
			yExit = yInvExit / b1.vy * ratio;
		}
		
		if (b1.vz == 0)
		{
			zEntry = -ENTRY_MAX;
			zExit = ENTRY_MAX;
		}
		else
		{
			zEntry = zInvEntry / b1.vz * ratio;
			zExit = zInvExit / b1.vz * ratio;
		}

		// find the earliest/latest times of collision
		cr.entryTime = Math.max(Math.max(xEntry, yEntry), zEntry);
		var exitTime:Float = Math.min(Math.min(xExit, yExit), zExit);
		
		// if there was no collision
		if (cr.entryTime > exitTime || xEntry < 0 && yEntry < 0 && zEntry < 0 || xEntry > ratio || yEntry > ratio || zEntry > ratio)
		{
			cr.normalX = 0;
			cr.normalY = 0;
			cr.normalZ = 0;
			cr.entryTime = ratio;
			cr.isCollided = false;
			return false;
		}
		else // if there was a collision
		{        		
			// calculate normal of collided surface
			cr.normalX = 0;
			cr.normalY = 0;
			cr.normalZ = 0;
			if (cr.entryTime==xEntry)
			{
				cr.normalX = getNormal(xInvEntry, b1.origin.x, b2.origin.x);
			}
			else if(cr.entryTime==yEntry)
			{
				cr.normalY = getNormal(yInvEntry, b1.origin.y, b2.origin.y);
			}else
			{
				cr.normalZ = getNormal(zInvEntry, b1.origin.z, b2.origin.z);
			}
			// return the time of collision
			
		}
		cr.isCollided =  true;
		return true;
	}
	private static function getNormal(invEntry:Float, pos1:Float, pos2:Float):Int{
		if (invEntry == 0){
			return pos2 < pos1 ? 1 : -1;
		}
		return invEntry<0 ? 1 : -1;
	}
	public static function sweptAABBResponse(b1:MovableAABB, b2:AABB, cr:SweepTestResult, responseType:Int):Bool{
		cr.isCollided = false;
		cr.normalX = 0;
		cr.normalY = 0;
		cr.normalZ = 0;
		cr.entryTime = 0;
		
		if (broadphase==null)
			broadphase = AABB.create();
		getSweptBroadphaseBox(b1, broadphase);
		if (!AABBCheck(broadphase, b2))
			return false;
		sweptAABB(b1, b2, cr);
		if (!cr.isCollided)
			return false;
		var remainingtime:Float = cr.ratio - cr.entryTime;
		var dotprod:Float;
		var vx:Float = b1.vx;
		var vy:Float = b1.vy;
		var vz:Float = b1.vz;
		
		b1.vx = b1.vx * cr.entryTime;
		b1.vy = b1.vy * cr.entryTime;
		b1.vz = b1.vz * cr.entryTime;
		switch responseType{
			case CollisionResponseType.PUSH:
				var magnitude:Float;
				if(b1.d==1){
					magnitude = Math.sqrt(vx * vx + vy * vy) * remainingtime;
					dotprod = vx * cr.normalY + vy * cr.normalX;
				}else{
					magnitude = Math.sqrt(vx * vx + vy * vy + vz * vz) * remainingtime;
					dotprod = vx * cr.normalY + vy * cr.normalZ + vz * cr.normalZ;
				}
				
				if (dotprod > 0)
					dotprod = 1;
				else if (dotprod < 0)
					dotprod = -1;
				vx = cr.normalX == 0 ? 0 : dotprod * magnitude;
				vy = cr.normalY == 0 ? 0 : dotprod * magnitude;
				vz = cr.normalZ == 0 ? 0 : dotprod * magnitude;
			case CollisionResponseType.SLIDE:
				/*if(b1.d==1)
					dotprod = (vx * cr.normalY + vy * cr.normalX) * remainingtime;
				else
					dotprod = (vx * cr.normalY + vy * cr.normalX + vz * cr.normalZ) * remainingtime;*/
				vx = cr.normalX == 0 ? vx * remainingtime : 0;
				vy = cr.normalY == 0 ? vy * remainingtime : 0;
				vz = cr.normalZ == 0 ? vz * remainingtime : 0;
			case CollisionResponseType.DEFLECT:
				vx *= remainingtime;
				vy *= remainingtime;
				vz *= remainingtime;
				if (Math.abs(cr.normalX) > 0)
					vx = -vx;
				if (Math.abs(cr.normalY) > 0)
					vy = -vy;
				if (Math.abs(cr.normalZ) > 0)
					vz = -vz;
			default:
				return true;
		}
		b1.vx += vx;
		b1.vy += vy;
		b1.vz += vz;
		return true;
	}
	public static function getSweptBroadphaseBox(b:MovableAABB, result:AABB):Void{
		result.origin.x = b.vx>0 ? b.origin.x : b.origin.x + b.vx;
		result.origin.y = b.vy>0 ? b.origin.y : b.origin.y + b.vy;
		result.origin.z = b.vz>0 ? b.origin.z : b.origin.z + b.vz;
		result.w = b.vx > 0 ? b.vx + b.w : b.w - b.vx;
		result.h = b.vy > 0 ? b.vy + b.h : b.h - b.vy;
		result.d = b.vz > 0 ? b.vz + b.d : b.d - b.vz;
	}
}