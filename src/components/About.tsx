import "./styles/About.css";

const About = () => {
  return (
    <div className="about-section" id="about">
      <div className="about-me">
        <h3 className="title">About Me</h3>
        <p className="para">
          I'm Timor - a Computer Science student who'd rather ship something
          real than just study it. I like taking a messy problem and turning
          it into a product people actually use: BaliHofesh grew to
          thousands of students, Relive ran live at my own wedding, and an
          exam-grading engine I built now scores real student answers.
          What pulled me toward applied AI wasn't the hype - it was the
          plumbing: prompts, guardrails, data pipelines, the parts that have
          to hold up when real people depend on them. I'm curious by
          default, I like owning a problem end to end, and before any of
          this I led intelligence-collection teams in the IDF - which is
          where the instinct for getting things right under pressure comes
          from.
        </p>
      </div>
    </div>
  );
};

export default About;
