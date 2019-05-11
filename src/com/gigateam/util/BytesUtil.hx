package com.gigateam.util;
import haxe.io.Bytes;

/**
 * ...
 * @author Tiger
 */
class BytesUtil 
{

	public function new() 
	{
		
	}
	public static function copyBytes(bytes:Bytes, offset:Int, length:Int):Array<Int>{
		var i:Int = 0;
		var arr:Array<Int> = [];
		for (i in offset...length + offset){
			arr.push(bytes.get(i));
		}
		return arr;
	}
	public static function writeUnsignedInt24(bytes:Bytes, pos:UInt, num:Int):UInt{
		bytes.set(pos, (num >> 16) & 0xff);
		pos++;
		bytes.set(pos, (num >> 8) & 0xff);
		pos++;
		bytes.set(pos, num & 0xff);
		return 3;
	}
	public static function readUnsignedInt24(bytes:Bytes, pos:UInt):UInt{
		var num:Int = 0;
		num |= bytes.get(pos)<<16;
		pos++;
		num |= bytes.get(pos)<<8;
		pos++;
		num |= bytes.get(pos) & 0xff;
		return num;
	}
	public static function writeUnsignedInt16(bytes:Bytes, pos:UInt, num:Int):UInt{
		bytes.set(pos, (num >> 8) & 0xff);
		pos++;
		bytes.set(pos, num & 0xff);
		return 2;
	}
	public static function readUnsignedInt16(bytes:Bytes, pos:UInt):UInt{
		var num:Int = 0;
		num |= bytes.get(pos)<<8;
		pos++;
		num |= bytes.get(pos) & 0xff;
		return num;
	}
	public static function writeUTF(bytes:Bytes, pos:UInt, str:String):UInt{
		var data:Bytes = Bytes.ofString(str);
		pos += writeUnsignedInt16(bytes, pos, data.length);
		bytes.blit(pos, data, 0, data.length);
		return data.length+2;
	}
	public static function readUTF(bytes:Bytes, pos:UInt, len:UInt):String{
		var data:Bytes = bytes.sub(pos, len);
		return data.toString();
	}
}