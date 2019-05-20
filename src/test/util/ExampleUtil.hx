package test.util;

/**
 * ...
 * @author 
 */
typedef Meta = {
	var rx:Float;
	var ry:Float;
	var rz:Float;
};

typedef BodyData = {
	var x:Float;
	var y:Float;
	var z:Float;
	var xLength:Float;
	var yLength:Float;
	var zLength:Float;
	var rx:Float;
	var ry:Float;
	var rz:Float;
	var meta:Meta;
};

class ExampleUtil 
{

	public function new() 
	{
		
	}
	
	public static function toSpaceTime(time:Float):Int{
		return Std.int(time * 1000);
	}
	
	public static function spaceSysTime():Int{
		return toSpaceTime(sysTime());
	}
	
	public static function sysTime():Float{
		return Sys.time();
	}
	
	
}