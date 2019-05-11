package com.gigateam.crypto.asym;
import haxe.crypto.Base64;
import haxe.io.Bytes;
import thx.BigInt;

/**
 * ...
 * @author Tiger
 */
class RSAKey 
{
	public var n:BigInt;
	public var e:BigInt;
	public var d:BigInt;
	public function new(_n:BigInt, _e:BigInt, _d:BigInt=null) 
	{
		n = _n;
		e = _e;
		d = _d;
	}
	public function isPair():Bool{
		return d >= 0;
	}
	public function toString():String{
		return _toString();
	}
	public function toPublicString():String{
		return _toString(true);
	}
	private function _toString(publicOnly:Bool = false):String{
		var str:String = n.toString() + "|" + e.toString();
		if (d != null && !publicOnly){
			str += "|" + d.toString();
		}
		var bytes:Bytes = Bytes.ofString(str);
		return Base64.encode(bytes);
	}
	public static function fromString(str:String):RSAKey{
		var bytes:Bytes = Base64.decode(str);
		var keys:Array<String> = bytes.toString().split("|");
		var key:RSAKey = new RSAKey(0, 0);
		key.n = BigInt.fromString(keys[0]);
		key.e = BigInt.fromString(keys[1]);
		if (keys.length == 3){
			key.d = BigInt.fromString(keys[2]);
		}
		return key;
	}
}