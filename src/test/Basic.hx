package test;
import com.gigateam.world.physics.entity.Space;
import com.gigateam.world.physics.shape.Vec;
import hxd.Key;
import test.util.ComboParser;
import test.util.ComboParser.InputCombo;
import test.util.EntityModel;
import test.util.InputComboType;
import test.util.KeyPoller;

/**
 * ...
 * @author 
 */
class Basic extends Base
{
	var poller:KeyPoller;
	var comboParser:ComboParser;
	static function main(){
		new Basic();
	}
	
	public function new() 
	{
		super();
	}
	
	override public function init():Void{
		super.init();
		
		var keys:Array<Int> = [Key.W, Key.S, Key.A, Key.D, Key.MOUSE_LEFT, Key.MOUSE_RIGHT, Key.SPACE];
		poller = new KeyPoller(keys);
		comboParser = new ComboParser(keys.length);
		
		comboParser.map(0, InputComboType.TOP);
		comboParser.map(1, InputComboType.BOTTOM);
		comboParser.map(2, InputComboType.LEFT);
		comboParser.map(3, InputComboType.RIGHT);
		comboParser.map(4, InputComboType.FIRE);
		comboParser.map(5, InputComboType.SECONDARY_FIRE);
		comboParser.map(6, InputComboType.JUMP);
		comboParser.onKeyChange(function(index:Int, isDown:Bool):Void{
			var key:Int = poller.getKeyByIndex(index);
			trace("key changed", key, isDown);
		});
		trace(s2d.width, s2d.height);
		
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
		s2d.mouseX;
		s2d.mouseY;
		var centerX:Int = Std.int(s2d.width / 2);
		var centerY:Int = Std.int(s2d.height / 2);
		sevents.setMousePos(centerX, centerY);
		poller.pollChanges(0, 0);
		var combo:InputCombo = poller.getPressed();
		comboParser.append(combo);
		super.update(dt);
	}
}