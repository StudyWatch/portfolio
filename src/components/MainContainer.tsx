import { lazy, PropsWithChildren, Suspense, useEffect, useState } from "react";
import About from "./About";
import Career from "./Career";
import Contact from "./Contact";
import Cursor from "./Cursor";
import HowIWork from "./HowIWork";
import Landing from "./Landing";
import Navbar from "./Navbar";
import OtherWork from "./OtherWork";
import SocialIcons from "./SocialIcons";
import WhatIDo from "./WhatIDo";
import Work from "./Work";
import setSplitText from "./utils/splitText";

const TechStack = lazy(() => import("./TechStack"));

const MainContainer = ({ children }: PropsWithChildren) => {
  const [isDesktopView, setIsDesktopView] = useState<boolean>(
    window.innerWidth > 1024
  );

  useEffect(() => {
    // Debounced: `isDesktopView` gates whether TechStack (a 24-body physics
    // scene) is mounted at all — an undebounced listener fires on every
    // intermediate frame of a window resize/drag, tearing the whole
    // simulation down and respawning it from scratch each time, which reads
    // as the cluster "exploding" for no interaction-related reason. Waiting
    // for resizing to settle means the desktop/mobile check only actually
    // runs once, after the resize is done.
    let timeoutId: ReturnType<typeof setTimeout>;
    const resizeHandler = () => {
      clearTimeout(timeoutId);
      timeoutId = setTimeout(() => {
        setSplitText();
        setIsDesktopView(window.innerWidth > 1024);
      }, 200);
    };
    setSplitText();
    setIsDesktopView(window.innerWidth > 1024);
    window.addEventListener("resize", resizeHandler);
    return () => {
      clearTimeout(timeoutId);
      window.removeEventListener("resize", resizeHandler);
    };
  }, []);

  return (
    <div className="container-main">
      <Cursor />
      <Navbar />
      <SocialIcons />
      {isDesktopView && children}
      <div id="smooth-wrapper">
        <div id="smooth-content">
          <div className="container-main">
            <Landing>{!isDesktopView && children}</Landing>
            <About />
            <WhatIDo />
            <HowIWork />
            <Career />
            <Work />
            <OtherWork />
            {isDesktopView && (
              <Suspense fallback={<div>Loading....</div>}>
                <TechStack />
              </Suspense>
            )}
            <Contact />
          </div>
        </div>
      </div>
    </div>
  );
};

export default MainContainer;
