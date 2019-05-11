package com.gigateam.util;

/**
 * @author Tiger
 */
interface ITask 
{
	function trigger(time:Float):Bool;
	function start(startTime:Float):Void;
	function disable():Void;
	function getTriggerTime():Float;
}