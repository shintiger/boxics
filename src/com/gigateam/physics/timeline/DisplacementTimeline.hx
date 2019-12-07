package com.gigateam.physics.timeline;
import com.gigateam.util.Debugger;
import com.gigateam.physics.Acceleration;
import com.gigateam.physics.Impulse;
import com.gigateam.physics.algorithm.Equation;
import com.gigateam.physics.shape.Vec;

/**
 * ...
 * @author Tiger
 */
class DisplacementTimeline extends Timeline
{
	public function new(time:Int, frameAlive:Int=100) 
	{
		super(time, frameAlive);
	}
	public override function insertKeyframe(keyframe:Keyframe, clearFramesAfter:Bool=false):Bool{
		var dKeyFrame:DisplacementKeyframe = cast keyframe;
		if (dKeyFrame==null)
		return false;
		return super.insertKeyframe(keyframe);
	}
	/*public function applyImpulse(impulse:Impulse, time:Int):Void{
		var keyframe:DisplacementKeyframe = asKeyframe(time);
		var lastKeyframe:DisplacementKeyframe = cast(lastFrame(time), DisplacementKeyframe);
		var accel:Acceleration = cast(keyframe.inertia, Acceleration);
		var impulseAccel:Acceleration = impulse.toAcceleration();
		
		//Gravity
		keyframe.blendAcceleration(impulseAccel);
		
		if(accel.accelerationZ!=0){
			var neverReach:Bool = ( accel.maxVelZ > accel.forceZ && accel.accelerationZ < 0 ) || 
								( accel.maxVelZ < accel.forceZ && accel.accelerationZ > 0 ) ;
			accel.maxVelZ = impulseAccel.maxVelZ;
		}
		
		insertKeyframe(keyframe);
	}*/
	public function asKeyframe(time:Int):DisplacementKeyframe{
		var o:Vec = new Vec(0, 0, 0);
		var accel:Acceleration = new Acceleration(0, 0, 0);
		var inertia:Vec = new Vec(0, 0, 0);
		
		var lastKeyframe:DisplacementKeyframe = cast lastFrame(time);
		//var lastAccel:Acceleration = cast(lastKeyframe.inertia, Acceleration);
		var lastAccel:Acceleration = lastKeyframe.acceleration;
		var lastInertia:Vec = lastKeyframe.inertia;
		
		var deltaTime:Float = (time-lastKeyframe.time) * 0.001;
		
		getPosition(time, o, inertia);
		
		o.x += lastKeyframe.origin.x;
		o.y += lastKeyframe.origin.y;
		o.z += lastKeyframe.origin.z;
		
		var keyframe:DisplacementKeyframe = new DisplacementKeyframe(time, inertia, o, accel);
		return keyframe;
	}
	public function getPosition(time:Int, o:Vec, inertia:Vec):Void{
		var lastKeyframe:DisplacementKeyframe = cast lastFrame(time);
		//var lastAccel:Acceleration = lastKeyframe.acceleration;
		//var lastInertia:Vertex = lastKeyframe.inertia;
		if (lastKeyframe == null){
			return;
		}
		var deltaTime:Float = (time-lastKeyframe.time) * 0.001;
		
		lastKeyframe.getPosition(o, deltaTime, inertia);
		return;
		/*
		inertia = inertia == null ? new Vertex(0, 0, 0) : inertia;
		if (lastKeyframe.durationX >= 0 && lastKeyframe.durationX <= deltaTime){
			o.x = Equation.axisDisplacement(lastInertia.x, lastAccel.accelerationX, lastKeyframe.durationX);
			o.x += Equation.axisDisplacement(lastKeyframe.acceleration.maxVelX, 0, deltaTime-lastKeyframe.durationX);
			inertia.x = lastKeyframe.acceleration.maxVelX;
		}else{
			o.x = Equation.axisDisplacement(lastInertia.x, lastAccel.accelerationX, deltaTime);
			inertia.x = Equation.axisVeolcityAt(lastInertia.x, lastAccel.accelerationX, deltaTime);
		}
		
		if (lastKeyframe.durationY>=0 && lastKeyframe.durationY <= deltaTime){
			o.y = Equation.axisDisplacement(lastInertia.y, lastAccel.accelerationY, lastKeyframe.durationY);
			o.y += Equation.axisDisplacement(lastKeyframe.acceleration.maxVelY, 0, deltaTime-lastKeyframe.durationY);
			inertia.y = lastKeyframe.acceleration.maxVelY;
		}else{
			o.y = Equation.axisDisplacement(lastInertia.y, lastAccel.accelerationY, deltaTime);
			inertia.y = Equation.axisVeolcityAt(lastInertia.y, lastAccel.accelerationY, deltaTime);
		}
		
		if (lastKeyframe.durationZ>=0 && lastKeyframe.durationZ <= deltaTime){
			o.z = Equation.axisDisplacement(lastInertia.z, lastAccel.accelerationZ, lastKeyframe.durationZ);
			o.z += Equation.axisDisplacement(lastKeyframe.acceleration.maxVelZ, 0, deltaTime-lastKeyframe.durationZ);
			inertia.z = lastKeyframe.acceleration.maxVelZ;
		}else{
			o.z = Equation.axisDisplacement(lastInertia.z, lastAccel.accelerationZ, deltaTime);
			inertia.z = Equation.axisVeolcityAt(lastInertia.z, lastAccel.accelerationZ, deltaTime);
		}
		*/
	}
	public function getPositionOnly(time:Int, o:Vec):Void{
		var lastKeyframe:DisplacementKeyframe = cast lastFrame(time);
		//var lastAccel:Acceleration = lastKeyframe.acceleration;
		//var lastInertia:Vertex = lastKeyframe.inertia;
		var deltaTime:Float = (time-lastKeyframe.time) * 0.001;
		
		lastKeyframe.getPosition(o, deltaTime);
		return;
		/*
		if (lastKeyframe.durationX>=0 && lastKeyframe.durationX <= deltaTime){
			o.x = Equation.axisDisplacement(lastInertia.x, lastAccel.accelerationX, lastKeyframe.durationX);
			o.x += Equation.axisDisplacement(lastKeyframe.acceleration.maxVelX, 0, deltaTime-lastKeyframe.durationX);
		}else{
			o.x = Equation.axisDisplacement(lastInertia.x, lastAccel.accelerationX, deltaTime);
		}
		
		if (lastKeyframe.durationY>=0 && lastKeyframe.durationY <= deltaTime){
			o.y = Equation.axisDisplacement(lastInertia.y, lastAccel.accelerationY, lastKeyframe.durationY);
			o.y += Equation.axisDisplacement(lastKeyframe.acceleration.maxVelY, 0, deltaTime-lastKeyframe.durationY);
		}else{
			o.y = Equation.axisDisplacement(lastInertia.y, lastAccel.accelerationY, deltaTime);
		}
		
		if (lastKeyframe.durationZ>=0 && lastKeyframe.durationZ <= deltaTime){
			o.z = Equation.axisDisplacement(lastInertia.z, lastAccel.accelerationZ, lastKeyframe.durationZ);
			o.z += Equation.axisDisplacement(lastKeyframe.acceleration.maxVelZ, 0, deltaTime-lastKeyframe.durationZ);
		}else{
			o.z = Equation.axisDisplacement(lastInertia.z, lastAccel.accelerationZ, deltaTime);
		}*/
	}
}