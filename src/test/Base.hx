package test;
import com.gigateam.world.physics.entity.Body;
import com.gigateam.world.physics.entity.BodyType;
import com.gigateam.world.physics.entity.Space;
import com.gigateam.world.physics.shape.Vec;
import h2d.Flow;
import h3d.Vector;
import h3d.prim.Cube;
import h3d.scene.Mesh;
import h3d.scene.fwd.DirLight;
import hxd.App;
import test.util.EntityModel;
import test.util.ExampleUtil;

/**
 * ...
 * @author 
 */
class Base extends App
{
	var fui:Flow;
	var collapsedTime:Float = 0;
	var space:Space;
	var dynamicBody:Array<EntityModel> = [];
	public function new() 
	{
		super();
	}
	override function init() 
	{
		fui = new Flow(s2d);
		fui.layout = FlowLayout.Vertical;
		fui.verticalSpacing = 5;
		fui.padding = 10;
		
		var light:DirLight = new DirLight(new Vector(0.5, 0.5, -0.5), s3d);
		light.enableSpecular = true;
		// set the ambient light to 30%
		s3d.lightSystem.ambientLight.set(0.3, 0.3, 0.3);
		
		space = new Space(0, new Vec(0, 0, -0.98));
	}
	
	override function update( dt : Float ):Void 
	{
		collapsedTime += dt;
		space.advance(ExampleUtil.toSpaceTime(collapsedTime));
		for (entity in dynamicBody){
			entity.updateDisplay();
		}
	}
	
	private static function createDisplayCube(size:Vec, coord:Vec, color:Int):Mesh
	{
		var prim:Cube = new Cube(size.x, size.y, size.z, true);
		var obj:Mesh;
		prim.unindex();
		prim.addNormals();
		prim.addUVs();
		obj = new Mesh(prim, s3d);
		// Std.int(Math.random()*0xFFFFFF)
		obj.material.color.setColor(color);
		obj.material.shadows = false;
		obj.setPosition(coord.x, coord.y, coord.z);
		return obj;
	}
	
	private static function createEntity(size:Vec, coord:Vec, bodyType:Int, color:Int, rot:Vec):EntityModel
	{
		switch(bodyType){
			case BodyType.STATIC:
				rot = new Vec();
			case BodyType.DYNAMIC:
				rot = rot;
			default:
				throw "Unknown bodyType";
		}
		var mesh:Mesh = createDisplayCube(size.x, size.y, size.z, coord.x, coord.y, coord.z, color);
		var body:Body = new Body(bodyType, coord.x, size.x, coord.y, size.y, coord.z, size.z, rot.x, rot.y, rot.z);
		var model:EntityModel = new EntityModel(body, mesh);
		return model;
	}
	
	private function addStatic(size:Vec, coord:Vec, bodyType:Int, rot:Vec, color:Int):EntityModel
	{
		var entity:EntityModel = createEntity(size, coord, bodyType, color, rot);
		space.spawnBody(entity.data, ExampleUtil.spaceSysTime());
	}
	
	private function addDynamic(size:Vec, coord:Vec, bodyType:Int, color:Int):EntityModel
	{
		var entity:EntityModel = createEntity(size, coord, bodyType, color, null);
		space.spawnBody(entity.data, ExampleUtil.spaceSysTime());
		dynamicBody.push(entity);
	}
}