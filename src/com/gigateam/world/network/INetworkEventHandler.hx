package com.gigateam.world.network;

/**
 * @author Tiger
 */
interface INetworkEventHandler 
{
	function handle(evt:NetworkEvent, localWorldTime:Int):Void;
}