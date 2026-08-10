import { useEffect, useRef, useState } from "react";
import "./styles/Loading.css";
import { useLoading } from "../context/LoadingProvider";
import { assetPath } from "../utils/assetPath";

import Marquee from "react-fast-marquee";

// Hard ceiling on how long the loading overlay can block the site. 3D
// (WebGL/GLB) init has its own error handling (see Scene.tsx) that reveals
// the site immediately on a known failure, but this is the last-resort net
// for anything that hangs without ever rejecting or resolving - a stalled
// fetch, a WASM (DRACO) decode that never settles, etc. The site must never
// stay behind this overlay forever. 12s (not 8s) because a cold-cache fetch
// + DRACO decode + GPU compile of the ~4.3MB hero GLB legitimately took
// 8-14s in production testing - an 8s cutoff was firing on ordinary slow
// connections, not just genuine failures (harmless either way since the
// avatar still fades in once loadCharacter() resolves, but this reduces how
// often a real, successful load gets preempted by the fallback).
const SAFETY_TIMEOUT_MS = 12000;

const Loading = ({ percent }: { percent: number }) => {
  const { setIsLoading } = useLoading();
  const [loaded, setLoaded] = useState(false);
  const [isLoaded, setIsLoaded] = useState(false);
  const [clicked, setClicked] = useState(false);
  // Both the natural percent-100 path and the safety timeout below can
  // trigger completion - guard so it only ever runs once (re-running would
  // re-fire initialFX's SplitText/GSAP setup on already-split DOM nodes).
  const completionTriggered = useRef(false);

  useEffect(() => {
    if (percent < 100 || completionTriggered.current) return;
    completionTriggered.current = true;
    const t = setTimeout(() => {
      setLoaded(true);
      setTimeout(() => {
        setIsLoaded(true);
      }, 1000);
    }, 600);
    return () => clearTimeout(t);
  }, [percent]);

  useEffect(() => {
    const failSafe = setTimeout(() => {
      if (completionTriggered.current) return;
      console.warn(
        "[Loading] Safety timeout reached - revealing the site regardless of 3D init state."
      );
      completionTriggered.current = true;
      setLoaded(true);
      setTimeout(() => setIsLoaded(true), 1000);
    }, SAFETY_TIMEOUT_MS);
    return () => clearTimeout(failSafe);
  }, []);

  useEffect(() => {
    import("./utils/initialFX").then((module) => {
      if (isLoaded) {
        setClicked(true);
        setTimeout(() => {
          if (module.initialFX) {
            module.initialFX();
          }
          setIsLoading(false);
        }, 900);
      }
    });
  }, [isLoaded]);

  function handleMouseMove(e: React.MouseEvent<HTMLElement>) {
    const { currentTarget: target } = e;
    const rect = target.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    target.style.setProperty("--mouse-x", `${x}px`);
    target.style.setProperty("--mouse-y", `${y}px`);
  }

  return (
    <>
      <div className="loading-header">
        <a href={assetPath("")} className="loader-title" data-cursor="disable">
          Timor Malul
        </a>
        <div className={`loaderGame ${clicked && "loader-out"}`}>
          <div className="loaderGame-container">
            <div className="loaderGame-in">
              {[...Array(27)].map((_, index) => (
                <div className="loaderGame-line" key={index}></div>
              ))}
            </div>
            <div className="loaderGame-ball"></div>
          </div>
        </div>
      </div>
      <div className="loading-screen">
        <div className="loading-marquee">
          <Marquee>
            <span> Applied AI Engineer</span> <span>Full-Stack Builder</span>
            <span> Applied AI Engineer</span> <span>Full-Stack Builder</span>
          </Marquee>
        </div>
        <div
          className={`loading-wrap ${clicked && "loading-clicked"}`}
          onMouseMove={(e) => handleMouseMove(e)}
        >
          <div className="loading-hover"></div>
          <div className={`loading-button ${loaded && "loading-complete"}`}>
            <div className="loading-container">
              <div className="loading-content">
                <div className="loading-content-in">
                  Loading <span>{percent}%</span>
                </div>
              </div>
              <div className="loading-box"></div>
            </div>
            <div className="loading-content2">
              <span>Welcome</span>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Loading;

export const setProgress = (setLoading: (value: number) => void) => {
  let percent: number = 0;

  let interval = setInterval(() => {
    if (percent <= 50) {
      let rand = Math.round(Math.random() * 5);
      percent = percent + rand;
      setLoading(percent);
    } else {
      clearInterval(interval);
      interval = setInterval(() => {
        percent = percent + Math.round(Math.random());
        setLoading(percent);
        if (percent > 91) {
          clearInterval(interval);
        }
      }, 2000);
    }
  }, 100);

  function clear() {
    clearInterval(interval);
    setLoading(100);
  }

  function loaded() {
    return new Promise<number>((resolve) => {
      clearInterval(interval);
      interval = setInterval(() => {
        if (percent < 100) {
          percent++;
          setLoading(percent);
        } else {
          resolve(percent);
          clearInterval(interval);
        }
      }, 2);
    });
  }
  return { loaded, percent, clear };
};
