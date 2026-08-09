import Scene from "./Scene";
import ErrorBoundary from "../ErrorBoundary";
import { useLoading } from "../../context/LoadingProvider";

const CharacterModel = () => {
  const { setLoading } = useLoading();
  return (
    <ErrorBoundary
      onError={() => {
        // Scene already catches its own known failure modes internally
        // (see Scene.tsx); this is the last-resort net for anything
        // unforeseen. Without it, an uncaught error here would unmount the
        // entire app instead of just the 3D hero — and force the loader to
        // 100% so the site isn't left stuck behind the loading overlay.
        setLoading(100);
      }}
    >
      <Scene />
    </ErrorBoundary>
  );
};

export default CharacterModel;
