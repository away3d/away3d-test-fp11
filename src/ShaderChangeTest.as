package
{

	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.ColorTransformMethod;
	import away3d.materials.methods.EffectMethodBase;
	import away3d.primitives.CubeGeometry;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Vector3D;

	/*
	* Tests reported bugs that produced glitches when changing the shader on a material ( i.e. adding or removing methods ).
	* No glitches observed on the Away3D release branch on July 2nd 2012.
	* */

	public class ShaderChangeTest extends Sprite
	{
		private var _view:View3D;
		private var _method:EffectMethodBase;
		private var _material:TextureMaterial;

		public function ShaderChangeTest() {
			super();

			// -----------------------
			// Init stage.
			// -----------------------

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 4;

			// -----------------------
			// Init 3D.
			// -----------------------

			_view = new View3D();
			_view.backgroundColor = 0xFFFFFF;
			_view.camera.position = new Vector3D( 1000, 1000, 1000 );
			_view.camera.lookAt( new Vector3D() );
			addChild( _view );

			var stats:Sprite = new AwayStats( _view );
			addChild( stats );

			// -----------------------
			// Init lights.
			// -----------------------

			var light:LightBase = new DirectionalLight();
			light.transform = _view.camera.transform.clone();
			_view.scene.addChild( light );
			var lightPicker:StaticLightPicker = new StaticLightPicker( [ light ] );

			// -----------------------
			// Init materials.
			// -----------------------

			var bmd:BitmapData = new BitmapData( 512, 512, false, 0xFF0000 );
			bmd.perlinNoise( 50, 50, 8, 1, false, true, 7, true );
			var bitmapTexture:BitmapTexture = new BitmapTexture( bmd );
			_material = new TextureMaterial( bitmapTexture );
			_material.lightPicker = lightPicker;

			_method = new ColorTransformMethod();
			ColorTransformMethod( _method ).colorTransform = new ColorTransform( 1, 0, 0, 1 );

			// -----------------------
			// Init Objects.
			// -----------------------

			var tri:Trident = new Trident();
			_view.scene.addChild( tri );

			var mesh:Mesh = new Mesh( new CubeGeometry( 500, 500, 500 ), _material );
			mesh.mouseEnabled = true;
			mesh.addEventListener( MouseEvent3D.MOUSE_OVER, onMeshMouseOver );
			mesh.addEventListener( MouseEvent3D.MOUSE_OUT, onMeshMouseOut );
			_view.scene.addChild( mesh );

			// -----------------------
			// Start loop.
			// -----------------------

			addEventListener( Event.ENTER_FRAME, enterframeHandler );
		}

		private function onMeshMouseOut( event:MouseEvent3D ):void {
			_material.removeMethod( _method );
		}

		private function onMeshMouseOver( event:MouseEvent3D ):void {
			_material.addMethod( _method );
		}

		private function enterframeHandler( event:Event ):void {
			_view.render();
		}
	}
}
