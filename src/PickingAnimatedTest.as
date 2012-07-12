package
{

	import away3d.animators.*;
	import away3d.animators.data.*;
	import away3d.core.pick.*;
	import away3d.entities.*;
	import away3d.events.*;
	import away3d.library.*;
	import away3d.library.assets.*;
	import away3d.loaders.parsers.*;
	import away3d.materials.*;
	import away3d.textures.*;

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
		private var _animator:SkeletonAnimator;
		private var _animationSet:SkeletonAnimationSet;
		private var _skeleton:Skeleton;
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
				_mesh.rotationY = 180;
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
			} else if (event.asset.assetType == AssetType.SKELETON) {
				_skeleton = event.asset as Skeleton;	
			} else if (event.asset.assetType == AssetType.ANIMATION_SET) {
				_animationSet = event.asset as SkeletonAnimationSet;
				_animator = new SkeletonAnimator(_animationSet, _skeleton);
				
				//apply animator to mesh
				_mesh.animator = _animator;
				//initialise animation data
				AssetLibrary.loadData( new HellKnight_Walk7(), null, "walk7", new MD5AnimParser() );
			}
			else if( event.asset.assetType == AssetType.ANIMATION_STATE ) {
				var state:SkeletonAnimationState = event.asset as SkeletonAnimationState;
				var name : String = event.asset.assetNamespace;
				_animationSet.addState(name, state);
				_animator.play( name );
				_animator.updateRootPosition = false;
			}
		}
	}
}
