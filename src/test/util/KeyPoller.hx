package test.util;
import hxd.Key;

/**
 * ...
 * @author 
 */


class KeyPoller 
{
	var cursorX:Float = 0;
	var cursorY:Float = 0;
	var keys:Array<Int>;
	var presseds:Array<Bool> = [];
	public function new(keys:Array<Int>) 
	{
		this.keys = keys;
		for (key in keys){
			presseds.push(false);
		}
	}
	
	public function pollChanges(deltaX:Float, deltaY:Float):Bool
	{
		var changed:Bool = false;
		cursorX += deltaX;
		cursorY += deltaY;
		if (deltaX != 0 || deltaY != 0){
			changed = true;
		}
		for (i in 0...keys.length){
			var key:Int = keys[i];
			var isDown:Bool = Key.isDown(key);
			if (isDown == presseds[i])
				continue;
			changed = true;
			presseds[i] = isDown;
		}
		return changed;
	}
	
	public function getPressed():InputCombo
	{
		var combo:InputCombo = {
			"key" : presseds.copy(),
			"cursorX" : cursorX,
			"cursorY" : cursorY
		}
		return combo;
	}
}