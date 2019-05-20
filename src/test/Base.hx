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
import hxd.Key;
import hxd.Stage;
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
		// set the ambient light to 30%d
		s3d.lightSystem.ambientLight.set(0.3, 0.3, 0.3);
		var dist = 30;
		s3d.camera.pos.set(Math.cos(1) * dist, Math.sin(1) * dist, dist * 0.7 * Math.sin(1));
		
		space = new Space(ExampleUtil.spaceSysTime(), new Vec(0, 0, -9.8));
	}
	
	override function update( dt : Float ):Void 
	{
		collapsedTime += dt;
		space.advance(ExampleUtil.spaceSysTime());
		for (entity in dynamicBody){
			entity.updateDisplay();
		}
	}
	
	private function createDisplayCube(size:Vec, coord:Vec, color:Int):Mesh
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
	
	private function createEntity(size:Vec, coord:Vec, bodyType:Int, color:Int, rot:Vec):EntityModel
	{
		switch(bodyType){
			case BodyType.STATIC:
				color = color * 1;
			case BodyType.DYNAMIC:
				rot = new Vec();
			default:
				throw "Unknown bodyType";
		}
		var mesh:Mesh = createDisplayCube(size, coord, color);
		mesh.setRotation(rot.x, rot.y, rot.z);
		var body:Body = new Body(bodyType, coord.x, size.x, coord.y, size.y, coord.z, size.z, rot.x, rot.y, rot.z);
		var model:EntityModel = new EntityModel(body, mesh);
		return model;
	}
	
	private function addStatic(size:Vec, coord:Vec, rot:Vec, color:Int):EntityModel
	{
		var entity:EntityModel = createEntity(size, coord, BodyType.STATIC, color, rot);
		space.spawnBody(entity.data, ExampleUtil.spaceSysTime());
		return entity;
	}
	
	private function addDynamic(size:Vec, coord:Vec, color:Int):EntityModel
	{
		var entity:EntityModel = createEntity(size, coord, BodyType.DYNAMIC, color, null);
		//entity.data.setGravity(new Vec(0, 0, -98));
		space.spawnBody(entity.data, ExampleUtil.spaceSysTime());
		dynamicBody.push(entity);
		return entity;
	}
	
	private function fromData(datas:Array<BodyData>):Array<EntityModel>{
		var models:Array<EntityModel> = [];
		for (data in datas){
			var coord:Vec = new Vec(data.x, data.y, data.z);
			var size:Vec = new Vec(data.xLength, data.yLength, data.zLength);
			var rot:Vec = new Vec(data.rx, data.ry, data.rz);
			addStatic(size, coord, rot, Std.random(0xffffff));
		}
		return models;
	}
}