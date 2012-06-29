package
{

	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.core.pick.PickingColliderType;
	import away3d.core.pick.PickingType;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.events.MouseEvent3D;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.OBJParser;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;




	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW")]
	public class UvTest extends TestBase
	{
		[Embed(source="/../embeds/head/head.obj", mimeType="application/octet-stream")]
		private var HeadAsset:Class;

		private var _painting:Boolean;
		private var _bitmap:Bitmap;
		private var _painter:Sprite;

		private const TEXTURE_SIZE:uint = 2048;

		public function UvTest() {
			super();
		}

		override protected function postInit():void {

			// uv _painter
			_painter = new Sprite();
			_painter.graphics.beginFill( 0xFF0000 );
			_painter.graphics.drawCircle( 0, 0, 10 );
			_painter.graphics.endFill();

			// Setup view.
			_view.backgroundColor = 0xCCCCCC;
			_view.antiAlias = 4;
			_view.forceMouseMove = true;

			// Choose global picking method
			_view.mousePicker = PickingType.RAYCAST_FIRST_ENCOUNTERED;
//			_view.mousePicker = PickingType.SHADER;

			// Init Objects.
			AssetLibrary.enableParser( OBJParser );
			loadModel( new HeadAsset() );
		}

		private function loadModel( data:ByteArray ):void {
			var parser:OBJParser = new OBJParser( 100 );
			parser.addEventListener( AssetEvent.ASSET_COMPLETE, onAssetComplete );
			parser.parseAsync( data );
		}

		private function onAssetComplete( event:AssetEvent ):void {
			if( event.asset.assetType == AssetType.MESH ) {
				initializeModel( event.asset as Mesh );
			}
		}

		private function initializeModel( model:Mesh ):void {

			// Apply materials.
			var bmd:BitmapData = new BitmapData( TEXTURE_SIZE, TEXTURE_SIZE, false, 0xFF0000 );
			bmd.perlinNoise( 50, 50, 8, 1, false, true, 7, true );
			_bitmap = new Bitmap( bmd );
			_bitmap.scaleX = _bitmap.scaleY = 0.125;
			_bitmap.x = stage.stageWidth - _bitmap.width;
			addChild( _bitmap );
			var bitmapTexture:BitmapTexture = new BitmapTexture( bmd );
			var textureMaterial:TextureMaterial = new TextureMaterial( bitmapTexture );
			textureMaterial.lightPicker = _lightPicker;
			model.material = textureMaterial;

			// Set up interactivity.
			//model.pickingCollider = PickingColliderType.AS3_FIRST_ENCOUNTERED;
			//model.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			//model.pickingCollider = PickingColliderType.PB_FIRST_ENCOUNTERED;
			model.pickingCollider = PickingColliderType.PB_BEST_HIT;

			// Apply interactivity.
			model.mouseEnabled = model.mouseChildren = model.shaderPickingDetails = true;
			enableMeshMouseListeners( model );

			_view.scene.addChild( model );
		}

		// ---------------------------------------------------------------------
		// MouseEvent handlers.
		// ---------------------------------------------------------------------

		override protected function onMeshMouseMove( event:MouseEvent3D ):void {
			super.onMeshMouseMove( event );
			if( _painting ) {
				var uv:Point = event.uv;
				var textureMaterial:TextureMaterial = Mesh( event.object ).material as TextureMaterial;
				var bmd:BitmapData = _bitmap.bitmapData;
				var x:uint = uint( TEXTURE_SIZE * uv.x );
				var y:uint = uint( TEXTURE_SIZE * uv.y );
				var matrix:Matrix = new Matrix();
				matrix.translate( x, y );
				bmd.draw( _painter, matrix );
				BitmapTexture( textureMaterial.texture ).invalidateContent();
			}
		}

		override protected function onMeshMouseDown( event:MouseEvent3D ):void {
			super.onMeshMouseDown( event );
			_painting = true;
		}

		override protected function onMeshMouseUp( event:MouseEvent3D ):void {
			super.onMeshMouseUp( event );
			_painting = false;
		}

		override protected function onMeshMouseOut( event:MouseEvent3D ):void {
			super.onMeshMouseOut( event );
			_painting = false;
		}

		override protected function stageMouseUpHandler( event:MouseEvent ):void {
			super.stageMouseUpHandler( event );
			_painting = false;
		}
	}
}
