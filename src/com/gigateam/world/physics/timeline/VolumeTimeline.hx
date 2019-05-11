package com.gigateam.world.physics.timeline;

/**
 * ...
 * @author Tiger
 */
class VolumeTimeline extends Timeline
{

	public function new(_offset:Int, max:Int, alive:Int=0) 
	{
		super(_offset, alive);
		var keyframe:VolumeKeyframe = new VolumeKeyframe(0);
		keyframe.max = max;
		keyframe.value = max;
		insertKeyframe(keyframe);
	}
	public function asKeyframe(time:Int):VolumeKeyframe{
		var lastKeyframe:VolumeKeyframe = cast lastFrame(time);
		var i:Int = lastKeyframe.dps.length;
		var value:Int = valueAt(time);
		var keyframe:VolumeKeyframe = lastKeyframe.clone();
		while (i-->0){
			var duration:Int = Std.int(keyframe.duration[i]*1000);
			var dps:Int = keyframe.dps[i];
			
			if (duration == 0){
				continue;
			}else if (time > (duration + keyframe.time)){
				keyframe.duration.splice(i, 1);
				keyframe.dps.splice(i, 1);
			}else{
				keyframe.duration[i] = ((duration + keyframe.time) - time)*0.001;
			}
		}
		keyframe.value = value;
		keyframe.time = time;
		return keyframe;
	}
	public function shapeAdd(num:Int, time:Int):VolumeKeyframe{
		var keyframe:VolumeKeyframe = asKeyframe(time);
		keyframe.value+= num;
		if (keyframe.value > keyframe.max){
			keyframe.value = keyframe.max;
		}else if (keyframe.value < 0){
			keyframe.value = 0;
		}
		insertKeyframe(keyframe);
		return keyframe;
	}
	public function addFilter(duration:Int, dps:Int, time:Int):Void{
		var keyframe:VolumeKeyframe = asKeyframe(time);
		keyframe.duration.push(duration * 0.001);
		keyframe.dps.push(dps);
		insertKeyframe(keyframe);
	}
	public function removeFilter(duration:Int, dps:Int, time:Int):Void{
		var keyframe:VolumeKeyframe = asKeyframe(time);
		var dur:Float = duration * 0.001;
		var index:Int = keyframe.duration.indexOf(dur);
		if (index < 0){
			return;
		}
		if (dps != keyframe.dps[index]){
			return;
		}
		keyframe.duration.slice(index, 1);
		keyframe.dps.slice(index, 1);
		insertKeyframe(keyframe);
	}
	public function valueAt(time:Int):Int{
		var lastKeyframe:VolumeKeyframe = cast lastFrame(time);
		if (lastKeyframe == null){
			return -1;
		}
		var dt:Float = (time-lastKeyframe.time) * 0.001;
		var plus:Int = 0;
		for (i in 0...lastKeyframe.dps.length){
			var dps:Int = lastKeyframe.dps[i];
			var duration:Float = lastKeyframe.duration[i];
			
			if (duration == 0 || duration>dt){
				plus += Std.int(dps * dt);
			}else{
				plus += Std.int(dps * duration);
			}
		}
		var result:Int = lastKeyframe.value+plus;
		if (result < 0){
			result = 0;
		}else if (result > lastKeyframe.max){
			result = lastKeyframe.max;
		}
		return result;
	}
}