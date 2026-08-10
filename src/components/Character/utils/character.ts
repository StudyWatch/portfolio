import * as THREE from "three";
import { DRACOLoader, GLTF, GLTFLoader } from "three-stdlib";
import { activeAvatarProfile } from "../avatarProfile";
import { assetPath } from "../../../utils/assetPath";

const setCharacter = (
  renderer: THREE.WebGLRenderer,
  scene: THREE.Scene,
  camera: THREE.PerspectiveCamera
) => {
  const loader = new GLTFLoader();
  const dracoLoader = new DRACOLoader();
  dracoLoader.setDecoderPath(assetPath("draco/"));
  loader.setDRACOLoader(dracoLoader);

  const loadCharacter = (glbPath: string = activeAvatarProfile.glbPath) => {
    return new Promise<GLTF | null>((resolve, reject) => {
      loader.load(
        glbPath,
        async (gltf) => {
          // This callback is async but nothing awaits it - without this
          // try/catch, a rejection from compileAsync (shader compile
          // failure, context loss, mobile GPU/memory pressure) would be an
          // unhandled rejection that never calls resolve() or reject(),
          // leaving loadCharacter()'s promise pending forever. That hang
          // would sail straight past the .catch() in Scene.tsx too, since
          // the promise never actually settles.
          try {
            const character = gltf.scene;
            await renderer.compileAsync(character, camera, scene);
            character.traverse((child: any) => {
              if (child.isMesh) {
                const mesh = child as THREE.Mesh;
                child.castShadow = true;
                child.receiveShadow = true;
                mesh.frustumCulled = true;
              }
            });
            resolve(gltf);
            dracoLoader.dispose();
          } catch (error) {
            console.error("Error compiling GLTF model:", error);
            reject(error);
          }
        },
        undefined,
        (error) => {
          console.error("Error loading GLTF model:", error);
          reject(error);
        }
      );
    });
  };

  return { loadCharacter };
};

export default setCharacter;
