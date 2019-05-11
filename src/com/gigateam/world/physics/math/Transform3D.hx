package com.gigateam.world.physics.math;

/**
 * ...
 * @author Tiger
 */
class Transform3D 
{
	public var a:Float = 1;
	public var b:Float = 0;
	public var c:Float = 0;
	public var d:Float = 0;

	public var e:Float = 0;
	public var f:Float = 1;
	public var g:Float = 0;
	public var h:Float = 0;

	public var i:Float = 0;
	public var j:Float = 0;
	public var k:Float = 1;
	public var l:Float = 0;
	public function new() 
	{
		
	}
	public function compose(x:Float, y:Float, z:Float, rotationX:Float, rotationY:Float, rotationZ:Float, scaleX:Float, scaleY:Float, scaleZ:Float):Void {
		var cosX:Float = Math.cos(rotationX);
		var sinX:Float = Math.sin(rotationX);
		var cosY:Float = Math.cos(rotationY);
		var sinY:Float = Math.sin(rotationY);
		var cosZ:Float = Math.cos(rotationZ);
		var sinZ:Float = Math.sin(rotationZ);
		var cosZsinY:Float = cosZ*sinY;
		var sinZsinY:Float = sinZ*sinY;
		var cosYscaleX:Float = cosY*scaleX;
		var sinXscaleY:Float = sinX*scaleY;
		var cosXscaleY:Float = cosX*scaleY;
		var cosXscaleZ:Float = cosX*scaleZ;
		var sinXscaleZ:Float = sinX*scaleZ;
		a = cosZ * cosYscaleX;
		b = cosZsinY*sinXscaleY - sinZ*cosXscaleY;
		c = cosZsinY*cosXscaleZ + sinZ*sinXscaleZ;
		d = x;
		e = sinZ*cosYscaleX;
		f = sinZsinY*sinXscaleY + cosZ*cosXscaleY;
		g = sinZsinY*cosXscaleZ - cosZ*sinXscaleZ;
		h = y;
		i = -sinY*scaleX;
		j = cosY*sinXscaleY;
		k = cosY*cosXscaleZ;
		l = z;
	}
	public function copy(source:Transform3D):Void {
		a = source.a;
		b = source.b;
		c = source.c;
		d = source.d;
		e = source.e;
		f = source.f;
		g = source.g;
		h = source.h;
		i = source.i;
		j = source.j;
		k = source.k;
		l = source.l;
	}
	public function append(transform:Transform3D):Void {
		var ta:Float = a;
		var tb:Float = b;
		var tc:Float = c;
		var td:Float = d;
		var te:Float = e;
		var tf:Float = f;
		var tg:Float = g;
		var th:Float = h;
		var ti:Float = i;
		var tj:Float = j;
		var tk:Float = k;
		var tl:Float = l;
		a = transform.a*ta + transform.b*te + transform.c*ti;
		b = transform.a*tb + transform.b*tf + transform.c*tj;
		c = transform.a*tc + transform.b*tg + transform.c*tk;
		d = transform.a*td + transform.b*th + transform.c*tl + transform.d;
		e = transform.e*ta + transform.f*te + transform.g*ti;
		f = transform.e*tb + transform.f*tf + transform.g*tj;
		g = transform.e*tc + transform.f*tg + transform.g*tk;
		h = transform.e*td + transform.f*th + transform.g*tl + transform.h;
		i = transform.i*ta + transform.j*te + transform.k*ti;
		j = transform.i*tb + transform.j*tf + transform.k*tj;
		k = transform.i*tc + transform.j*tg + transform.k*tk;
		l = transform.i*td + transform.j*th + transform.k*tl + transform.l;
	}
}