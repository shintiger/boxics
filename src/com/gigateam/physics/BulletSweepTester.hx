package com.gigateam.physics;
import com.gigateam.util.Debugger;
import com.gigateam.world.entity.Director;
import com.gigateam.physics.algorithm.SweepTestResult;
import com.gigateam.physics.entity.Body;
import com.gigateam.physics.entity.ISweepTester;
import com.gigateam.physics.entity.Space;
import com.gigateam.physics.shape.AABB;
import com.gigateam.physics.shape.AABBTree;
import com.gigateam.physics.shape.MovableAABB;

/**
 * ...
 * @author Tiger
 */
class BulletSweepTester implements ISweepTester
{
	private var _hittable:AABBTree;
	private var _director:Director;
	public function new(director:Director) 
	{
		_director = director;
		_hittable = new AABBTree(10);
	}
	public function sweepTest(body:Body, space:Space, broadphase:AABB, colliding:AABB, earliest:SweepTestResult, worldTime:Int, testTime:Int):AABB{
		var victim:AABB = Space.bodySweepTest(body, _hittable, broadphase, earliest);
		if (victim != null){
			_director.scored(body.getAABB(), victim, worldTime);
		}
		return colliding;
	}
	public function add(aabb:MovableAABB):Void{
		_hittable.add(aabb);
		_hittable.update();
	}
	public function remove(aabb:MovableAABB):Void{
		_hittable.remove(aabb);
		_hittable.update();
	}
	public function update(time:Int):Void{
		_hittable.update();
	}
}