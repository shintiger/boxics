package test.util;

/**
 * ...
 * @author 
 */
typedef OnChangeCallback:Int->Bool->Void;

typedef InputCombo = {
	var key:Array<Bool>;
	var cursorX:Float;
	var cursorY:Float;
};
 
class ComboParser
{
	var numKeys:Int = -1;
	public function new(keyCount:Int) 
	{
		numKeys = keyCount;
	}
}