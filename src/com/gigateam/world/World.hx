package com.gigateam.world;
import com.gigateam.crypto.asym.RSA;
import com.gigateam.crypto.asym.RSAKey;
import com.gigateam.crypto.asym.RSAKeyGenerator;
import com.gigateam.util.Benchmark;
import com.gigateam.world.physics.TestTemplate;
import com.gigateam.world.physics.algorithm.SweepTestResult;
import com.gigateam.world.physics.shape.AABB;
import com.gigateam.world.physics.shape.Vertex;
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
