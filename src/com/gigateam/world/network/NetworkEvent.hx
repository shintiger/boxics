package com.gigateam.world.network;
import com.gigateam.world.logic.BytesStream;
import com.gigateam.world.network.Payload.Packable;
import haxe.io.Bytes;

/**
 * ...
 * @author Tiger
 */
class NetworkEvent implements Packable
{
	public static inline var SCORED:Int = 100;
	public static inline var BINARY:Int = 101;
	private static inline var fold:Int = 100000;
	public var dataLength:Int = -1;
	public var data:BytesStream;
	public var x:Float = 0;
	public var y:Float = 0;
	public var z:Float = 0;
	public var type:Int;
	public var time:Int = -1;
	public function new(contentFormat:Int=-1) 
	{
		//data = new BytesStream(
		type = contentFormat;
	}
	public function pack(bytes:BytesStream, worldTime:Int = 0):Int{
		var originOffset:Int = bytes.offset();
		
		if (time < 0){
			throw "Missing event timestamp";
		}
		bytes.writeInt24(type);
		bytes.writeInt24(time);
		switch(type){
			case SCORED:
				bytes.writeInt32(Std.int(x * fold));
				bytes.writeInt32(Std.int(y * fold));
				bytes.writeInt32(Std.int(z * fold));
			case BINARY:
				data.setOffset(0);
				bytes.writeInt16(dataLength);
				bytes.writeStream(data, dataLength);
		}
		
		return bytes.offset() - originOffset;
	}
	public function unpack(bytes:BytesStream, remoteWorldTime:Int = 0, localWorldTime:Int = 0):Int{
		var originOffset:Int = bytes.offset();
		
		type = bytes.readInt24();
		time = bytes.readInt24();
		switch(type){
			case SCORED:
				x = bytes.readInt32() / fold;
				y = bytes.readInt32() / fold;
				z = bytes.readInt32() / fold;
			case BINARY:
				if (data == null){
					data = new BytesStream(Bytes.alloc(1024), 0);
				}else{
					data.setOffset(0);
				}
				dataLength = bytes.readInt16();
				bytes.readStream(data, dataLength);
		}
		
		return bytes.offset() - originOffset;
	}
}