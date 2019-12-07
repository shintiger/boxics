package com.gigateam.physics.entity;
import com.gigateam.physics.algorithm.SweepTestResult;
import com.gigateam.physics.shape.AABB;

/**
 * @author Tiger
 */
interface ISweepTester 
{
	function sweepTest(body:Body, space:Space, broadphase:AABB, colliding:AABB, earliest:SweepTestResult, worldTime:Int, testTime:Int):AABB;
}