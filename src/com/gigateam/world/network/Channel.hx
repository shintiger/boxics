package com.gigateam.world.network;

/**
 * ...
 * @author Tiger
 */
class Channel implements ISubscriber
{
	public var id:Int=-1;
	private var parent:Channel;
	private var children:Array<ISubscriber> = [];
	public function new(cid:Int) 
	{
		id = cid;
	}
	public function add(channel:ISubscriber):Void{
		if (!Std.is(channel, Client) && !Std.is(channel, Channel)){
			throw "Only support either Channel or Client.";
		}
		children.push(channel);
	}
	public function remove(channel:ISubscriber):Void{
		var index:Int = children.indexOf(channel);
		if (index < 0){
			return;
		}
		children.remove(channel);
	}
	public function wasPassed(time:Int):Bool{
		var i:Int;
		for (i in 0...children.length){
			if (Std.is(children[i], Channel)){
				var channel:Channel = cast children[i];
				if (!channel.wasPassed(time)){
					return false;
				}
				continue;
			}
			var client:Client = cast children[i];
			if (time > client.ackedSnapshotTime){
				return false;
			}
		}
		return true;
	}
}