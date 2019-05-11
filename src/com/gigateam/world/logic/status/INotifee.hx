package com.gigateam.world.logic.status;

/**
 * @author Tiger
 */
interface INotifee 
{
	function timesup(notifier:Notifier, time:Float):Bool;
}