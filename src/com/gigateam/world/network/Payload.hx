package com.gigateam.world.network;
import com.gigateam.world.entity.Entity;
import com.gigateam.world.logic.BytesStream;
import haxe.ds.GenericStack;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
/**
 * ...
 * @author Tiger
 */
interface Packable{
	public function pack(bytes:BytesStream, worldTime:Int=0):Int;
	public function unpack(bytes:BytesStream, remoteWorldTime:Int=0, localWorldTime:Int=0):Int;
}
interface NetworkEntity extends Packable{
	public var libId:Int;
	public var networkId:Int;
}
class Payload implements Packable
{
	public static inline var HEADER_LENGTH:Int = 3;
	public static inline var MAX:Int = 255;
	private var _children:GenericStack<Packable>;
	public function new() 
	{
		_children = new GenericStack<Packable>();
	}
	public function addChild(payload:Packable):Void{
		_children.add(payload);
	}
	public function removeChild(payload:Packable):Void{
		_children.remove(payload);
	}
	public function pack(bytes:BytesStream, worldTime:Int=0):Int{
		return 0;
	}
	public function unpack(bytes:BytesStream, remoteWorldTime:Int=0, localWorldTime:Int=0):Int{
		return 0;
	}
	public static function create():Payload{
		var payload:Payload = new Payload();
		return payload;
	}
	public static function dispose(payload:Payload):Void{
		
	}
}