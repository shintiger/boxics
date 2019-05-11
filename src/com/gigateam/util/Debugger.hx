package com.gigateam.util;
import com.gigateam.world.logic.BytesStream;
import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;

/**
 * ...
 * @author Tiger
 */
class Debugger 
{
	public static var MAX_REPEAT:Int = 3;
	private inline static var BUFFER_LENGTH:Int = 50;
	private var repeating:Int = 0;
	private var position:Int = 0;
	private var lastOutput:String = "";
	private var buffer:Vector<String>;
	private var debugStr:String = "";
	private static var _instance:Debugger;
	public function new() 
	{
		if (_instance == null){
			_instance = this;
			clear();
		}else{
			throw "Debugger is singleton";
		}
	}
	public static function getInstance():Debugger{
		if (_instance == null){
			new Debugger();
		}
		return _instance;
	}
	public function setString(str:String):Void{
		debugStr = str;
	}
	public function getString():String{
		return debugStr;
	}
	
	public function log(toApppend:String):Void{
		if (position >= BUFFER_LENGTH){
			return;
		}
		buffer.set(position, toApppend);
		position++;
	}
	public function get():String{
		var output:String = "";
		var i:Int = 0;
		while (true){
			if (i == position)
			break;
			output += String.fromCharCode(10) + buffer[i];
			i++;
		}
		clear();
		if (MAX_REPEAT>0){
			if (lastOutput == output){
				repeating++;
				if (repeating >= MAX_REPEAT){
					return "";
				}
			}else{
				repeating = 0;
				lastOutput = output;
			}
		}
		return output;
	}
	public function isEmpty():Bool{
		return position == 0;
	}
	private function clear():Void{
		buffer = new Vector<String>(BUFFER_LENGTH);
		position = 0;
	}
	public function length():UInt{
		return position;
	}
	public function throwError():Void{
		var e:Debugger = null;
		e.clear();
	}
	public function bytesToHex(bytesStream:BytesStream):String{
		var offset:Int = bytesStream.offset();
		var len:Int = bytesStream.length() - 1;
		var str:String = "";
		bytesStream.setOffset(0);
		while (len > 0){
			str += StringTools.hex(bytesStream.read(), 2) + " ";
			len -= 1;
		}
		bytesStream.setOffset(offset);
		return str;
	}
}