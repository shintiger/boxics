package com.gigateam.world.logic;

/**
 * ...
 * @author Tiger
 */
class KeyState 
{
	private var _bytes:Int = 0;
	private var _delta:Int = 0;
	public function new(bytes:Int) 
	{
		_bytes = bytes;
	}
	public function isUpdated():Bool{
		return _delta != 0;
	}
	public function update(bytes:Int):Void{
		_delta = _bytes^bytes;
		_bytes = bytes;
	}
	public function isPressed(seq:UInt):Bool{
		return (_bytes & (1 << seq)) != 0;
	}
	public function isChanged(seq:UInt):Bool{
		return (_delta & (1 << seq)) != 0;
	}
	public function justPressed(seq:UInt):Bool{
		return isPressed(seq) && isChanged(seq);
	}
	public function changed(seq:UInt):Int{
		return _delta & (1 << seq);
	}
	public function pressed(seq:UInt):Int{
		return _bytes & (1 << seq);
	}
	public function getBytes():Int{
		return _bytes;
	}
}