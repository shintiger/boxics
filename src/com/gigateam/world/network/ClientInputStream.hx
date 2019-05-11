package com.gigateam.world.network;
import com.gigateam.world.logic.BytesStream;
import com.gigateam.world.network.Payload.Packable;
import haxe.ds.GenericStack;
import haxe.io.Bytes;

/**
 * ...
 * @author Tiger
 */
interface IInputStream{
	public function createInput(time:Int, transformX:Float, transformY:Float, keyBytes:Int):ClientInput;
}
class ClientInputStream implements Packable
{
	private var stream:Array<ClientInput>;
	private var acked:Int;
	private var offsetTime:Int;
	public function new(time:Int) 
	{
		offsetTime = time;
		stream = [];
	}
	public function append(input:ClientInput):Int{
		if (stream.length>0 && stream[stream.length - 1].time >= input.time){
			return -1;
		}
		stream.push(input);
		return 0;
	}
	public function reset(time:Int):Void{
		offsetTime = time;
	}
	public function ack(time:Int):Int{
		var i:Int = 0;
		while (stream.length>0){
			if (stream[0].time > time)
				break;
			stream.shift();
			i++;
		}
		return i;
	}
	public function pack(bytes:BytesStream, worldTime:Int=0):Int{
		var offset:Int = bytes.offset();
		for (s in stream){
			offset += s.pack(bytes);
		}
		return offset;
	}
	public function unpack(bytes:BytesStream, remoteWorldTime:Int=0, localWorldTime:Int=0):Int{
		while (bytes.offset() < bytes.length()){
			var input:ClientInput = new ClientInput(0, 0, 0, 0);
			input.unpack(bytes, remoteWorldTime, localWorldTime);
			if (input.time < acked)
			continue;
			
			acked = input.time;
			stream.push(input);
		}
		return bytes.offset();
	}
	public function ackedTime():Int{
		return acked;
	}
	public function getRaw():Array<ClientInput>{
		return stream;
	}
	public function dispose():Void{
	}
}