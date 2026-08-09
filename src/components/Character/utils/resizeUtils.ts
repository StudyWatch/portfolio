import * as THREE from "three";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { setCharTimeline, setAllTimeline } from "../../utils/GsapScroll";
import type { CommandScreens } from "./screens";
import { computeCameraPlan } from "./cameraFit";

export default function handleResize(
  renderer: THREE.WebGLRenderer,
  camera: THREE.PerspectiveCamera,
  canvasDiv: React.RefObject<HTMLDivElement>,
  character: THREE.Object3D,
  screens: CommandScreens,
  headBone: THREE.Object3D | null
) {
  if (!canvasDiv.current) return;
  let canvas3d = canvasDiv.current.getBoundingClientRect();
  const width = canvas3d.width;
  const height = canvas3d.height;
  renderer.setSize(width, height);
  camera.aspect = width / height;
  camera.updateProjectionMatrix();
  const workTrigger = ScrollTrigger.getById("work");
  ScrollTrigger.getAll().forEach((trigger) => {
    if (trigger != workTrigger) {
      trigger.kill();
    }
  });
  const size = new THREE.Box3().setFromObject(character).getSize(new THREE.Vector3());
  const cameraPlan = computeCameraPlan(camera, character, headBone);
  camera.position.set(
    cameraPlan.heroTarget.x,
    cameraPlan.heroTarget.y,
    cameraPlan.heroTarget.z + cameraPlan.heroDistance
  );
  camera.lookAt(cameraPlan.heroTarget);
  setCharTimeline(character, camera, screens, size, cameraPlan);
  setAllTimeline();
}
