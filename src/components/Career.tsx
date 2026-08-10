import "./styles/Career.css";

const Career = () => {
  return (
    <div className="career-section section-container">
      <div className="career-container">
        <h2>
          My career <span>&</span>
          <br /> experience
        </h2>
        <div className="career-info">
          <div className="career-timeline">
            <div className="career-dot"></div>
          </div>
          <div className="career-info-box">
            <div className="career-info-in">
              <div className="career-role">
                <h4>Commander, Combat Intelligence Collection</h4>
                <h5>IDF - Unit 414</h5>
              </div>
              <h3>2020–2023</h3>
            </div>
            <p>
              Led operational teams and managed sensitive systems under
              pressure - the same discipline that now runs production
              infrastructure for real users.
            </p>
          </div>
          <div className="career-info-box">
            <div className="career-info-in">
              <div className="career-role">
                <h4>Founder &amp; Full-Stack Developer</h4>
                <h5>BaliHofesh</h5>
              </div>
              <h3>2024</h3>
            </div>
            <p>
              Built and shipped an AI-powered student platform for the Open
              University of Israel solo - auth, RLS, dual payment rails, a
              tutor marketplace, and 50+ Supabase edge functions.
            </p>
          </div>
          <div className="career-info-box">
            <div className="career-info-in">
              <div className="career-role">
                <h4>Applied AI &amp; Full-Stack Developer</h4>
                <h5>Independent - B.Sc. CS, Open University of Israel</h5>
              </div>
              <h3>NOW</h3>
            </div>
            <p>
              Finishing my degree while building production AI systems: a
              fail-closed exam-grading engine with shadow-mode calibration,
              and Relive - a realtime event-media platform with its own AI
              moderation pipeline.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Career;
