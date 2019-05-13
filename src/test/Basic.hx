package test;
import com.gigateam.world.physics.entity.Space;
import com.gigateam.world.physics.shape.Vec;
import hxd.Key;
import test.util.EntityModel;

/**
 * ...
 * @author 
 */
class Basic extends Base
{ 
	static function main(){
		new Basic();
	}
	
	public function new() 
	{
		super();
	}
	
	override public function init():Void{
		super.init();
		addStatic(new Vec(1, 1, 1), new Vec(0, 0, 0), new Vec(0, 0, -0.465), Std.random(0xffffff));
		addStatic(new Vec(1, 1, 1), new Vec(1, 0, 0), new Vec(0, 0, 1), Std.random(0xffffff));
		addStatic(new Vec(1, 1, 1), new Vec(0, 1, 0), new Vec(0, 0, 2), Std.random(0xffffff));
		addDynamic(new Vec(1, 1, 1), new Vec(0, 0, 10), Std.random(0xffffff));
	}
	
	override function mainLoop() {
		/*
		if( Key.isDown(Key.CTRL) && Key.isPressed("S".code) ) {
			var bytes = s3d.serializeScene();
			hxd.File.saveBytes("scene.hsd", bytes);
		}
		*/
		super.mainLoop();
	}
	
	override public function update(dt:Float):Void{
		super.update(dt);
	}
}