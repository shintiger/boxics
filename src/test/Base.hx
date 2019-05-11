package test;
import h2d.Flow;
import h3d.Vector;
import h3d.scene.fwd.DirLight;
import hxd.App;

/**
 * ...
 * @author 
 */
class Base extends App
{
	var fui:Flow;
	var collapsedTime:Float = 0;
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
		
		
		
	}
	
	override function update( dt : Float ):Void 
	{
		collapsedTime += dt;
		//trace(collapsedTime);
		//s3d.camera.pos.set(Math.cos(collapsedTime) * dist, Math.sin(collapsedTime) * dist, dist * 0.7 * Math.sin(collapsedTime));
	}
	
	private function addStatic():Void
	{
		
	}
	
	private function addDynamic():Void
	{
		
	}
}