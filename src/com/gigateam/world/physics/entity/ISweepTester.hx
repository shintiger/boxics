package com.gigateam.world.physics.entity;
import com.gigateam.world.physics.algorithm.SweepTestResult;
import com.gigateam.world.physics.shape.AABB;

/**
 * @author Tiger
 */
interface ISweepTester 
{
	function sweepTest(body:Body, space:Space, broadphase:AABB, colliding:AABB, earliest:SweepTestResult, worldTime:Int, testTime:Int):AABB;
}