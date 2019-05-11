package com.gigateam.world.physics.timeline;
import com.gigateam.world.physics.Acceleration;
import com.gigateam.world.physics.Impulse;
import com.gigateam.world.physics.algorithm.Equation;
import com.gigateam.world.physics.shape.Vertex;

/**
 * ...
 * @author Tiger
 */
class DisplacementKeyframe extends Keyframe 
{
	public var durationX:Float = -1;
	public var durationY:Float = -1;
	public var durationZ:Float = -1;
	public var inertia:Vertex;
	public var acceleration:Acceleration;
	public var origin:Vertex;
	private var deccelEndDisplacement:Vertex;
	private var deccelEndInertia:Vertex;
	private var accel:Acceleration;
	private var deccel:Acceleration;
	private var concentric:Float = 1;
	private var deccelDurationX:Float =-1;
	private var deccelDurationY:Float =-1;
	private var deccelDurationZ:Float =-1;
	public function new(_time:Int, inert:Vertex, o:Vertex, accelerate:Acceleration) 
	{
		super(_time);
		inertia = inert;
		acceleration = accelerate;
		deccelEndDisplacement = new Vertex();
		origin = o.clone();
	}
	public function durationMax():Int{
		return Std.int(Math.max(Math.max(durationX, durationY), durationZ));
	}
	public function durationMin():Int{
		return Std.int(Math.min(Math.min(durationX, durationY), durationZ));
	}
	public function applyImpulse(impulse:Impulse):Float{
		inertia.x += impulse.x * impulse.w;
		inertia.y += impulse.y * impulse.w;
		inertia.z += impulse.z * impulse.w;
		
		return inertia.z;
	}
	private static function getDecceleration(force:Float, acceleration:Float, friction:Float, gravity:Float=0):Float{
		var forceZero:Bool = (force == gravity);
		var accelZero:Bool = (acceleration == gravity);
		if (forceZero || (!accelZero && (acceleration > gravity) == (force > gravity))){
			return 0;
		}
		if (accelZero){
			if (force > 0){
				return Math.min(friction, -friction);
			}else{
				return Math.max(friction, -friction);
			}
		}
		//When force and acceleration are not zero, and force and acceleration are reversed way
		return acceleration + ((force > 0)?Math.min(friction, -friction):Math.max(friction, -friction));
	}
	public function applyFriction(friction:Float, targetVelocity:Vertex):Void{
		/*concentric = friction;
		
		deccel = new Acceleration();
		accel = new Acceleration();
		accel.cloneFrom(acceleration);
		
		deccel.maxVelX = 0;
		deccel.maxVelY = 0;
		deccel.maxVelZ = 0;
		
		var deccelVel:Float;
		var force:Float;
		
		deccelEndInertia = inertia.clone();
		deccelVel = getDecceleration(inertia.x, accel.accelerationX, concentric, targetVelocity.x);
		if (deccelVel == 0){
			deccelDurationX = 0;
		}else{
			deccelDurationX = Equation.axisExceedVelTime(inertia.x, deccelVel, gravity.x);
			deccelEndDisplacement.x = Equation.axisDisplacement(inertia.x, deccelVel, deccelDurationX);
			deccel.accelerationX = deccelVel;
			deccelEndInertia.x = 0;
		}
		
		deccelVel = getDecceleration(inertia.y, accel.accelerationY, concentric, targetVelocity.y);
		if (deccelVel == 0){
			deccelDurationY = 0;
		}else{
			deccelDurationY = Equation.axisExceedVelTime(inertia.y, deccelVel, gravity.y);
			deccelEndDisplacement.y = Equation.axisDisplacement(inertia.y, deccelVel, deccelDurationY);
			deccel.accelerationY = deccelVel;
			deccelEndInertia.y = 0;
		}
		
		deccelVel = getDecceleration(inertia.z, accel.accelerationZ, concentric, targetVelocity.z);
		if (deccelVel == 0){
			deccelDurationZ = 0;
		}else{
			deccelDurationZ = Equation.axisExceedVelTime(inertia.z, deccelVel, gravity.z);
			deccelEndDisplacement.z = Equation.axisDisplacement(inertia.z, deccelVel, deccelDurationZ);
			deccel.accelerationZ = deccelVel;
			deccelEndInertia.z = 0;
		}
		
		var posFric:Float = Math.max(concentric, -concentric);
		var negFric:Float = Math.min(concentric, -concentric);
		
		if (accel.accelerationX==0 || Math.abs(accel.accelerationX) <= posFric){
			durationX = 0;
		}else{
			accel.accelerationX -= (accel.accelerationX > 0) ? negFric : posFric;
			durationX = Equation.axisExceedVelTime(deccelEndInertia.x, accel.accelerationX, accel.maxVelX);
		}
		
		if (accel.accelerationY==0 || Math.abs(accel.accelerationY) <= posFric){
			durationY = 0;
		}else{
			accel.accelerationY -= (accel.accelerationY > 0) ? negFric : posFric;
			durationY = Equation.axisExceedVelTime(deccelEndInertia.y, accel.accelerationY, accel.maxVelY);
		}
		
		if (accel.accelerationZ==0 || Math.abs(accel.accelerationZ) <= posFric){
			durationZ = 0;
		}else{
			accel.accelerationZ -= (accel.accelerationZ > 0) ? negFric : posFric;
			durationZ = Equation.axisExceedVelTime(deccelEndInertia.z, accel.accelerationZ, accel.maxVelZ);
		}
		
		durationX += deccelDurationX;
		durationY += deccelDurationY;
		durationZ += deccelDurationZ;*/
	}
	public function getPosition(o:Vertex, deltaTime:Float, force:Vertex = null):Void{
		var updateForce:Bool = force != null;
		if (durationX >= 0 && durationX <= deltaTime){
			o.x = Equation.axisDisplacement(inertia.x, acceleration.accelerationX, durationX);
			o.x += Equation.axisDisplacement(acceleration.maxVelX, 0, deltaTime-durationX);
			if (updateForce){
				force.x = acceleration.maxVelX;
			}
		}else{
			o.x = Equation.axisDisplacement(inertia.x, acceleration.accelerationX, deltaTime);
			if (updateForce){
				force.x = Equation.axisVeolcityAt(inertia.x, acceleration.accelerationX, deltaTime);
			}
		}
		
		if (durationY>=0 && durationY <= deltaTime){
			o.y = Equation.axisDisplacement(inertia.y, acceleration.accelerationY, durationY);
			o.y += Equation.axisDisplacement(acceleration.maxVelY, 0, deltaTime-durationY);
			if (updateForce){
				force.y = acceleration.maxVelY;
			}
		}else{
			o.y = Equation.axisDisplacement(inertia.y, acceleration.accelerationY, deltaTime);
			if (updateForce){
				force.y = Equation.axisVeolcityAt(inertia.y, acceleration.accelerationY, deltaTime);
			}
		}
		
		if (durationZ>=0 && durationZ <= deltaTime){
			o.z = Equation.axisDisplacement(inertia.z, acceleration.accelerationZ, durationZ);
			o.z += Equation.axisDisplacement(acceleration.maxVelZ, 0, deltaTime-durationZ);
			if (updateForce){
				force.z = acceleration.maxVelZ;
			}
		}else{
			o.z = Equation.axisDisplacement(inertia.z, acceleration.accelerationZ, deltaTime);
			if (updateForce){
				force.z = Equation.axisVeolcityAt(inertia.z, acceleration.accelerationZ, deltaTime);
			}
		}
	}
	public function getPosition2Way(o:Vertex, deltaTime:Float, force:Vertex=null):Void{
		var tier:Int = 1;
		
		//Start X axis--------------------------------------------------------------------------------------------------------
		if (durationX > 0){
			if (deltaTime >= durationX){
				tier = 3;
				o.x = deccelEndDisplacement.x+Equation.axisDisplacement(deccelEndInertia.x, accel.accelerationX, durationX);
				o.x += Equation.axisDisplacement(accel.maxVelX, 0, deltaTime-durationX);
			}else if (deccelDurationX > 0){
				if (deltaTime >= deccelDurationX){
					tier = 2;
					o.x = deccelEndDisplacement.x+Equation.axisDisplacement(deccelEndInertia.x, accel.accelerationX, deltaTime);
				}else{
					tier = 1;
					o.x = Equation.axisDisplacement(inertia.x, deccel.accelerationX, deltaTime);
				}
			}else{
				tier = 0;
			}
		}else{
			tier = 0;
		}
		if (tier == 0){
			o.x = Equation.axisDisplacement(inertia.x, accel.accelerationX, deltaTime);
		}
		if (force != null){
			switch(tier){
				case 0:
					force.x = Equation.axisVeolcityAt(inertia.x, accel.accelerationX, deltaTime);
				case 1:
					force.x = Equation.axisVeolcityAt(inertia.x, deccel.accelerationX, deltaTime);
				case 2:
					force.x = Equation.axisVeolcityAt(deccelEndInertia.x, accel.accelerationX, deltaTime);
				default:
					force.x = accel.maxVelX;
			}
		}
		//Start Y axis--------------------------------------------------------------------------------------------------------
		if (durationY > 0){
			if (deltaTime >= durationY){
				tier = 3;
				o.y = deccelEndDisplacement.y+Equation.axisDisplacement(deccelEndInertia.y, accel.accelerationY, durationY);
				o.y += Equation.axisDisplacement(accel.maxVelY, 0, deltaTime-durationY);
			}else if (deccelDurationY > 0){
				if (deltaTime >= deccelDurationY){
					tier = 2;
					o.y = deccelEndDisplacement.y+Equation.axisDisplacement(deccelEndInertia.y, accel.accelerationY, deltaTime);
				}else{
					tier = 1;
					o.y = Equation.axisDisplacement(inertia.y, deccel.accelerationY, deltaTime);
				}
			}else{
				tier = 0;
			}
		}else{
			tier = 0;
		}
		if (tier == 0){
			o.y = Equation.axisDisplacement(inertia.y, accel.accelerationY, deltaTime);
		}
		if (force != null){
			switch(tier){
				case 0:
					force.y = Equation.axisVeolcityAt(inertia.y, accel.accelerationY, deltaTime);
				case 1:
					force.y = Equation.axisVeolcityAt(inertia.y, deccel.accelerationY, deltaTime);
				case 2:
					force.y = Equation.axisVeolcityAt(deccelEndInertia.y, accel.accelerationY, deltaTime);
				default:
					force.y = accel.maxVelY;
			}
		}
		//Start Z axis--------------------------------------------------------------------------------------------------------
		if (durationZ > 0){
			if (deltaTime >= durationZ){
				tier = 3;
				o.z = deccelEndDisplacement.z+Equation.axisDisplacement(deccelEndInertia.z, accel.accelerationZ, durationZ);
				o.z += Equation.axisDisplacement(accel.maxVelZ, 0, deltaTime-durationZ);
			}else if (deccelDurationZ > 0){
				if (deltaTime >= deccelDurationZ){
					tier = 2;
					o.z = deccelEndDisplacement.z+Equation.axisDisplacement(deccelEndInertia.z, accel.accelerationZ, deltaTime);
				}else{
					tier = 1;
					o.z = Equation.axisDisplacement(inertia.z, deccel.accelerationZ, deltaTime);
				}
			}else{
				tier = 0;
			}
		}else{
			tier = 0;
		}
		if (tier == 0){
			o.y = Equation.axisDisplacement(inertia.y, accel.accelerationY, deltaTime);
		}
		if (force != null){
			switch(tier){
				case 0:
					force.z = Equation.axisVeolcityAt(inertia.z, accel.accelerationZ, deltaTime);
				case 1:
					force.z = Equation.axisVeolcityAt(inertia.z, deccel.accelerationZ, deltaTime);
				case 2:
					force.z = Equation.axisVeolcityAt(deccelEndInertia.z, accel.accelerationZ, deltaTime);
				default:
					force.z = accel.maxVelZ;
			}
		}
	}
	public function updateDuration():Void{
		durationX = (acceleration.accelerationX==0) ? -1 : Equation.axisExceedVelTime(inertia.x, acceleration.accelerationX, acceleration.maxVelX);	
		durationY = (acceleration.accelerationY==0) ? -1 : Equation.axisExceedVelTime(inertia.y, acceleration.accelerationY, acceleration.maxVelY);
		durationZ = (acceleration.accelerationZ==0) ? -1 : Equation.axisExceedVelTime(inertia.z, acceleration.accelerationZ, acceleration.maxVelZ);
	}
	public static function isReachable(velocity:Float, acceleration:Float, targetVelocity:Float):Bool{
		return (targetVelocity == velocity) || 
				(targetVelocity > velocity && acceleration > 0) || 
				(targetVelocity < velocity && acceleration < 0);
	}
}