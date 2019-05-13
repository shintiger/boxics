package test.util;

/**
 * ...
 * @author 
 */
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