package
{

	import agt.controllers.camera.FreeFlyCameraController;

	import away3d.cameras.lenses.FreeMatrixLens;

	import away3d.cameras.lenses.OrthographicLens;
	import away3d.cameras.lenses.OrthographicOffCenterLens;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.core.pick.PickingColliderType;
	import away3d.core.pick.PickingType;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.OBJParser;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;

	import flash.geom.Vector3D;

	[ SWF( backgroundColor="#000000", frameRate="60" ) ]
	public class PickingOrthographicTest extends PickingTestBase
	{
		public function PickingOrthographicTest() {
			super();
		}

		override protected function postInit():void {

			// Setup view.
			_view.backgroundColor = 0xCCCCCC;
			_view.antiAlias = 4;
			_view.forceMouseMove = true;
			_view.mousePicker = PickingType.RAYCAST_FIRST_ENCOUNTERED;
//			_view.camera.lens = new PerspectiveLens();
			_view.camera.lens = new OrthographicLens();
//			_view.camera.lens = new OrthographicOffCenterLens( -1000, 1000, -1000, 1000 );
//			_view.camera.lens = new FreeMatrixLens();

			// Init scene objects.
			var i:uint, j:uint, k:uint;
			var nx:uint = 3;
			var ny:uint = 3;
			var nz:uint = 3;
			var size:Number = 25;
			var dw:Number = 2 * size;
			var dh:Number = 2 * size;
			var dd:Number = 2 * size;
			var spacing:Number = Math.sqrt( dh * dh + dw * dw ) / 2;
			var offsetX:Number = -( nx * dw + ( nx - 1 ) * spacing ) / 2;
			var offsetY:Number = -( ny * dh + ( ny - 1 ) * spacing ) / 2;
			var offsetZ:Number = -( nz * dd + ( nz - 1 ) * spacing ) / 2;
			var cubeGeometry:CubeGeometry = new CubeGeometry( 50, 50, 50 );
			var cubeMaterial:ColorMaterial = new ColorMaterial( 0xFF0000 );
			cubeMaterial.lightPicker = _lightPicker;
			for( i = 0; i < nx; ++i ) {
				for( j = 0; j < ny; ++j ) {
					for( k = 0; k < nz; ++k ) {
						var object:Mesh = new Mesh( cubeGeometry, cubeMaterial );
						_view.scene.addChild( object );
						// Picking.
						object.mouseEnabled = object.mouseChildren = object.shaderPickingDetails = true;
						object.pickingCollider = PickingColliderType.AS3_FIRST_ENCOUNTERED;
						enableMeshMouseListeners( object );
						// Grid position.
						object.x = offsetX + ( dw + spacing ) * i + dw / 2;
						object.y = offsetY + ( dh + spacing ) * j + dh / 2;
						object.z = offsetZ + ( dd + spacing ) * k + dd / 2;
						// Random orientation.
//						object.rotationX = rand( -180, 180 );
//						object.rotationY = rand( -180, 180 );
//						object.rotationZ = rand( -180, 180 );
					}
				}
			}
		}
	}
}
