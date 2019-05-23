package test.util;

/**
 * ...
 * @author 
 */
typedef OnChangeCallback = Int->Bool->Void;

typedef InputCombo = {
	var key:Array<Bool>;
	var cursorX:Float;
	var cursorY:Float;
};
 
class ComboParser
{
	var combos:Array<InputCombo> = [];
	var numKeys:Int = -1;
	var keyTypes:Map<Int, Int>;
	var keyCodes:Map<Int, Int>;
	var callback:OnChangeCallback;
	public function new(keyCount:Int) 
	{
		numKeys = keyCount;
		keyTypes = new Map<Int, Int>();
		keyCodes = new Map<Int, Int>();
	}
	
	public function onKeyChange(callback:OnChangeCallback):Void
	{
		this.callback = callback;
	}
	
	public function onDirectionChange(callback:
	
	public function map(keyIndex:Int, keyType:Int):Void
	{
		if (keyCodes.exists(keyType)){
			throw "Duplicate keyType.";
		}
		keyTypes.set(keyIndex, keyType);
		keyCodes.set(keyType, keyIndex);
	}
	
	public function append(combo:InputCombo):Void
	{
		if(combos.length>0){
			var last:InputCombo = combos[combos.length - 1];
			for (i in 0...last.key.length){
				if (last.key[i] != combo.key[i]){
					if (callback != null){
						callback(i, combo.key[i]);
					}
				}
			}
		}
		combos.push(combo);
	}
}