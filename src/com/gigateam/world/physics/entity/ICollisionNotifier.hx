package com.gigateam.world.physics.entity;
import com.gigateam.world.physics.shape.AABB;
import com.gigateam.world.physics.shape.Vec;

/**
 * @author Tiger
 */
interface ICollisionNotifier 
{
	function collisionStart(body:Body, dirction:Vec, colliding:AABB, worldTime:Int):Void;
	function collisionEnd(body:Body, dirction:Vec, colliding:AABB, worldTime:Int):Void;
	function fall(body:Body, worldTime:Int):Void;
	function land(body:Body, worldTime:Int):Void;
}