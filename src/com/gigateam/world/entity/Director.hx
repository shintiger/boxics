package com.gigateam.world.entity;
import com.gigateam.world.network.NetworkEvent;
import com.gigateam.world.physics.algorithm.SweepTestResult;
import com.gigateam.world.physics.entity.Body;
import com.gigateam.world.physics.entity.ISweepTester;
import com.gigateam.world.physics.entity.Space;
import com.gigateam.world.physics.shape.AABB;

/**
 * ...
 * @author Tiger
 */
class Director
{

	public function new() 
	{
		
	}
	public function dispatchEvent(evt:NetworkEvent):Void{
		
	}
	public function spawnEntity(time:Int, groupId:Int, libId:Int, x:Float = 0, y:Float = 0, z:Float = 0, center:Bool=false):Entity{
		return null;
	}
	public function unSpawnEntity(time:Int, entity:Entity):Void{
		
	}
	public function scored(bullet:AABB, victim:AABB, worldTime:Int):Void{
		
	}
	public function handle(evt:NetworkEvent, worldTime:Int):Void{
		
	}
}