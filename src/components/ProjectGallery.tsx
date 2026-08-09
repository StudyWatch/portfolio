import { useState } from "react";
import { MdArrowOutward, MdChevronLeft, MdChevronRight } from "react-icons/md";
import type { MediaGroup } from "../data/projects";
import "./styles/ProjectGallery.css";

interface Props {
  groups: MediaGroup[];
  projectName: string;
  link?: string;
}

/**
 * Tabs (only shown when a project has more than one MediaGroup) + a
 * crossfade carousel underneath. Deliberately manual-only navigation — no
 * autoplay — per the "no overwhelming auto-play behavior" brief. Items are
 * typed image | video (see data/projects.ts) so a group can later mix in a
 * looping MP4/WebM demo without any change to this component.
 */
const ProjectGallery = ({ groups, projectName, link }: Props) => {
  const [groupIndex, setGroupIndex] = useState(0);
  const [slideIndex, setSlideIndex] = useState(0);

  const activeGroup = groups[groupIndex];
  const items = activeGroup.items;
  const hasMultipleGroups = groups.length > 1;
  const hasMultipleSlides = items.length > 1;

  const selectGroup = (index: number) => {
    setGroupIndex(index);
    setSlideIndex(0);
  };

  const step = (delta: number) => {
    setSlideIndex((current) => (current + delta + items.length) % items.length);
  };

  return (
    <div className="project-gallery">
      {hasMultipleGroups && (
        <div className="project-gallery-tabs" role="tablist">
          {groups.map((group, index) => (
            <button
              key={group.label}
              type="button"
              role="tab"
              aria-selected={index === groupIndex}
              className={`project-gallery-tab${
                index === groupIndex ? " is-active" : ""
              }`}
              onClick={() => selectGroup(index)}
            >
              {group.label}
            </button>
          ))}
        </div>
      )}

      <div className="project-gallery-viewport">
        {items.map((item, index) => (
          <div
            key={item.src}
            className={`project-gallery-slide${
              index === slideIndex ? " is-active" : ""
            }`}
            aria-hidden={index !== slideIndex}
          >
            {item.type === "video" ? (
              <video
                src={item.src}
                poster={item.poster}
                muted
                loop
                playsInline
                autoPlay
                controls={false}
              />
            ) : (
              <img
                src={item.src}
                alt={item.alt}
                loading={index === 0 ? "eager" : "lazy"}
              />
            )}
          </div>
        ))}

        {hasMultipleSlides && (
          <>
            <button
              type="button"
              className="project-gallery-arrow prev"
              aria-label={`Previous ${projectName} screenshot`}
              onClick={() => step(-1)}
            >
              <MdChevronLeft />
            </button>
            <button
              type="button"
              className="project-gallery-arrow next"
              aria-label={`Next ${projectName} screenshot`}
              onClick={() => step(1)}
            >
              <MdChevronRight />
            </button>
          </>
        )}

        {link && (
          <a
            className="project-gallery-link"
            href={link}
            target="_blank"
            rel="noreferrer"
            data-cursor="disable"
            aria-label={`Open ${projectName}`}
          >
            <MdArrowOutward />
          </a>
        )}
      </div>

      {hasMultipleSlides && (
        <div className="project-gallery-dots">
          {items.map((item, index) => (
            <button
              key={item.src}
              type="button"
              className={`project-gallery-dot${
                index === slideIndex ? " is-active" : ""
              }`}
              aria-label={`Go to ${projectName} screenshot ${index + 1}`}
              onClick={() => setSlideIndex(index)}
            />
          ))}
        </div>
      )}
    </div>
  );
};

export default ProjectGallery;
