package
{

	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.core.base.SubMesh;
	import away3d.core.pick.PickingColliderType;
	import away3d.core.pick.PickingType;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.events.MouseEvent3D;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.AWD2Parser;
	import away3d.loaders.parsers.Parsers;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.primitives.LineSegment;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import mx.events.ResourceEvent;




	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW")]
	public class PickingHeavyObjectTest extends PickingTestBase
	{
		[Embed(source="/../embeds/head/head.awd", mimeType="application/octet-stream")]
		private var HeadAsset:Class;

		[Embed(source="/../embeds/troll/troll.AWD", mimeType="application/octet-stream")]
		private var TrollAsset:Class;

		private var _model:ObjectContainer3D;

		public function PickingHeavyObjectTest() {
			super();
		}

		override protected function postInit():void {

			// Setup view.
			_view.backgroundColor = 0xCCCCCC;
			_view.antiAlias = 4;
			_view.forceMouseMove = true;

			// Choose global picking method
			_view.mousePicker = PickingType.RAYCAST_BEST_HIT;
//			_view.mousePicker = PickingType.SHADER;

			// Init Objects.
			AssetLibrary.enableParser( AWD2Parser );
//			AssetLibrary.enableParsers( Parsers.ALL_BUNDLED );
			loadModel( new TrollAsset() );
		}

		private function loadModel( data:ByteArray ):void {
			if( _model ) {
				_view.scene.removeChild( _model );
			}
			_model = new ObjectContainer3D();
			AssetLibrary.addEventListener( AssetEvent.ASSET_COMPLETE, onAssetComplete );
			AssetLibrary.addEventListener( LoaderEvent.RESOURCE_COMPLETE, onResourceComplete );
			AssetLibrary.loadData( data );
		}

		private function onAssetComplete( event:AssetEvent ):void {
			var isVisibleEntity:Boolean =
					event.asset.assetType == AssetType.CONTAINER ||
					event.asset.assetType == AssetType.ENTITY ||
					event.asset.assetType == AssetType.MESH;
			if( isVisibleEntity ) {
				_model.addChild( event.asset as ObjectContainer3D );
			}
		}

		private function onResourceComplete( event:LoaderEvent ):void {

			// Apply materials.
			var redMaterial:ColorMaterial = new ColorMaterial( 0xFF0000 );
			redMaterial.lightPicker = _lightPicker;
//			iterateContainerChildrenMeshes( _model, applyMaterial, redMaterial );
			iterateContainerChildrenMeshes( _model, applyRandomMaterialsOnSubMeshes );

			// Set up interactivity.
//			_model.pickingCollider = PickingColliderType.BOUNDS_ONLY;
//			_model.pickingCollider = PickingColliderType.AS3_FIRST_ENCOUNTERED;
			_model.pickingCollider = PickingColliderType.PB_FIRST_ENCOUNTERED;
//			_model.pickingCollider = PickingColliderType.AS3_BEST_HIT;

			// Apply interactivity.
			_model.mouseEnabled = _model.mouseChildren = _model.shaderPickingDetails = true;
			enableMeshMouseListeners( _model );

			_view.scene.addChild( _model );
		}

		// ---------------------------------------------------------------------
		// Utils.
		// ---------------------------------------------------------------------

		private function applyRandomMaterialsOnSubMeshes( mesh:Mesh, params:Array ):void {
			var i:uint, len:uint;
			len = mesh.subMeshes.length;
			for( i = 0; i < len; i++ ) {
				var subMesh:SubMesh = mesh.subMeshes[ i ];
				var randMaterial:ColorMaterial = new ColorMaterial( Math.floor( 0xFFFFFF * Math.random() ) );
				randMaterial.lightPicker = _lightPicker;
				subMesh.material = randMaterial;
			}
		}

		private function applyMaterial( mesh:Mesh, params:Array ):void {
			var material:MaterialBase = params[ 0 ];
			mesh.material = material;
		}

		private function iterateContainerChildrenMeshes( container:ObjectContainer3D, execFunction:Function, ...params ):void {

			var child:Object3D;
			var i:uint, len:uint;

			len = container.numChildren;
			for( i = 0; i < len; i++ ) {
				child = container.getChildAt( i );
				if( child is Mesh ) {
					execFunction( child as Mesh, params );
				}
				else if( child is ObjectContainer3D ) {
					iterateContainerChildrenMeshes( child as ObjectContainer3D, execFunction, params );
				}
			}

		}
	}
}
