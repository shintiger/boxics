package com.gigateam.util;

/**
 * ...
 * @author Tiger
 */
class Benchmark 
{

	public function new() 
	{
		
	}
	public static function multiplication(seed:Float, loop:UInt):Float{
		var arr:Array<Int> = [12345, 23564, 84569, 15536, 18895, 15325, 16859];
		var len:Int = arr.length;
		var newRatio:Float = 1 / len;
		var oldRatio:Float = (len - 1) / len;
		for (i in 0...loop){
			var index:Int = i % len;
			seed = seed * oldRatio + arr[index] * newRatio;
		}
		return seed;
	}
}