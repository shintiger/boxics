package test;
import com.gigateam.world.physics.entity.Space;
import com.gigateam.world.physics.shape.Vec;

/**
 * ...
 * @author 
 */
class Basic extends Base
{
	var space:Space;
	
	static function main(){
		new Basic();
	}
	
	public function new() 
	{
		super();
	}
	
	override public function init():Void{
		super.init();
		space = new Space(0, new Vec(0, 0, -0.98));
	}
	
	override public function update(dt:Float):Void{
		super.update(dt);
		space.advance(collapsedTime);
	}
}