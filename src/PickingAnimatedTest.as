package
{

	import away3d.animators.SmoothSkeletonAnimator;
	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.data.SkeletonAnimationState;
	import away3d.core.pick.PickingColliderType;
	import away3d.core.pick.PickingType;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.MD5AnimParser;
	import away3d.loaders.parsers.MD5MeshParser;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;

	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW")]
	public class PickingAnimatedTest extends PickingTestBase
	{
		// Textures.
		// body diffuse map
		[Embed(source="/../embeds/hellknight/hellknight_diffuse.jpg")]
		private var BodyDiffuse:Class;
		// body normal map
		[Embed(source="/../embeds/hellknight/hellknight_normals.png")]
		private var BodyNormals:Class;
		// body specular map
		[Embed(source="/../embeds/hellknight/hellknight_specular.png")]
		private var BodySpecular:Class;
		
		// Mesh.
		[Embed(source="/../embeds/hellknight/hellknight.md5mesh", mimeType="application/octet-stream")]
		private var HellKnight_Mesh:Class;
		
		// Animations.
		[Embed(source="/../embeds/hellknight/walk7.md5anim", mimeType="application/octet-stream")]
		private var HellKnight_Walk7:Class;

		private var _bodyMaterial:TextureMaterial;
		private var _animator:SmoothSkeletonAnimator;
		private var _mesh:Mesh;

		public function PickingAnimatedTest() {
			super();
		}

		override protected function postInit():void {

			// Setup view.
			_view.backgroundColor = 0xCCCCCC;
			_view.antiAlias = 4;
			_view.forceMouseMove = true;

			// Choose global picking method
//			_view.mousePicker = PickingType.RAYCAST_BEST_HIT;
			_view.mousePicker = PickingType.SHADER;

			// Init materials.
			_bodyMaterial = new TextureMaterial( new BitmapTexture( new BodyDiffuse().bitmapData ) );
			_bodyMaterial.specularMap = new BitmapTexture( new BodySpecular().bitmapData );
			_bodyMaterial.normalMap = new BitmapTexture( new BodyNormals().bitmapData );
			_bodyMaterial.lightPicker = _lightPicker;

			// Init Objects.
			loadModel();
		}

		private function loadModel():void {
			AssetLibrary.addEventListener( AssetEvent.ASSET_COMPLETE, onAssetComplete );
			AssetLibrary.loadData( new HellKnight_Mesh(), null, null, new MD5MeshParser() );
		}

		private function onAssetComplete( event:AssetEvent ):void {
			if( event.asset.assetType == AssetType.MESH ) {

				// Initialize material.
				_mesh = event.asset as Mesh;
				_mesh.scale( 3 );
				_mesh.material = _bodyMaterial;
				_mesh.castsShadows = true;
				_mesh.showBounds = true;
				_view.scene.addChild( _mesh );

				// Set up interactivity.
				_mesh.pickingCollider = PickingColliderType.PB_BEST_HIT;
				//_mesh.pickingCollider = PickingColliderType.AS3_BEST_HIT;
				
				// Apply interactivity.
				_mesh.mouseEnabled = _mesh.mouseChildren = _mesh.shaderPickingDetails = true;
				enableMeshMouseListeners( _mesh );

				//initialise animation data
				loadAnimations();
			}
			else if( event.asset.assetType == AssetType.ANIMATION ) {
				var seq:SkeletonAnimationSequence = event.asset as SkeletonAnimationSequence;
				seq.name = event.asset.assetNamespace;
				seq.looping = true;
				_animator.addSequence(seq);
				_animator.play( "walk7" );
			}
		}

		private function loadAnimations():void {
			_animator = new SmoothSkeletonAnimator( _mesh.animationState as SkeletonAnimationState );
			_animator.updateRootPosition = false;
			_animator.timeScale = 0.1;
			AssetLibrary.loadData( new HellKnight_Walk7(), null, "walk7", new MD5AnimParser() );
		}
	}
}
