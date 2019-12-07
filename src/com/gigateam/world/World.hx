package com.gigateam.world;
import com.gigateam.physics.algorithm.SweepTestResult;
import com.gigateam.physics.shape.AABB;
import com.gigateam.physics.shape.Vec;
import haxe.Json;


typedef Parsed = {
	var a:Int;
	var b:String;
	var c:Array<String>;
};
class World {
	private static var simulator:WorldSimulator;
	public static function main() {
		//simulator = new WorldSimulator();
	}
	public function new() 
	{
	}
	public static function calc(xdd:Int):Int{
		return xdd * 4;
	}
	public function calc2(xdd:Int):Int{
		return xdd;
	}
	public static function getSimulator():WorldSimulator{
		if (simulator == null){
			simulator = new WorldSimulator();
		}
		return simulator;
	}
	public static function teskLeak():Int{
		var ew:SweepTestResult = new SweepTestResult();
		return 0;
	}
}
