import "./styles/OtherWork.css";

interface OtherProject {
  name: string;
  description: string;
  tech: string;
  link: string;
}

// Lighter treatment, deliberately — these are earlier/smaller projects, not
// flagship case studies. Everything else built (a handful of thin client
// demos, an unedited AI-builder prototype, coursework) was left out.
const otherProjects: OtherProject[] = [
  {
    name: "StudyWatch",
    description:
      "Language-learning platform that extracts vocabulary from real TV episodes and turns it into quizzes and games.",
    tech: "React · Node.js · PostgreSQL · AI word extraction",
    link: "https://studywatch-swart.vercel.app/",
  },
  {
    name: "Shift Scheduler",
    description:
      "Constraint-based employee shift scheduler with rules, conflicts, and Excel export for real-world scheduling.",
    tech: "React · TypeScript · Supabase · ExcelJS",
    link: "https://bois-beta.vercel.app/",
  },
  {
    name: "SmartPacking",
    description:
      "Generates personalized packing checklists for trips, with realtime state and offline support.",
    tech: "React · Supabase · Zustand",
    link: "https://smartpacking.vercel.app",
  },
];

const OtherWork = () => {
  return (
    <div className="other-work-section section-container">
      <h2>
        Other <span>Work</span>
      </h2>
      <div className="other-work-grid">
        {otherProjects.map((project) => (
          <a
            className="other-work-card"
            key={project.name}
            href={project.link}
            target="_blank"
            rel="noreferrer"
            data-cursor="disable"
          >
            <h3>{project.name}</h3>
            <p>{project.description}</p>
            <span>{project.tech}</span>
          </a>
        ))}
      </div>
    </div>
  );
};

export default OtherWork;
