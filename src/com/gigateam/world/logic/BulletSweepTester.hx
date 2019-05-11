package com.gigateam.world.logic;
import com.gigateam.util.Debugger;
import com.gigateam.world.entity.Director;
import com.gigateam.world.physics.algorithm.SweepTestResult;
import com.gigateam.world.physics.entity.Body;
import com.gigateam.world.physics.entity.ISweepTester;
import com.gigateam.world.physics.entity.Space;
import com.gigateam.world.physics.shape.AABB;
import com.gigateam.world.physics.shape.AABBTree;
import com.gigateam.world.physics.shape.MovableAABB;

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