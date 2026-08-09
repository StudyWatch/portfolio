import { MdArrowOutward, MdCopyright } from "react-icons/md";
import "./styles/Contact.css";

const Contact = () => {
  return (
    <div className="contact-section section-container" id="contact">
      <div className="contact-container">
        <h3>Contact</h3>
        <div className="contact-flex">
          <div className="contact-box">
            <h4>Email</h4>
            <p>
              <a href="mailto:timor34@gmail.com" data-cursor="disable">
                timor34@gmail.com
              </a>
            </p>
            <h4>Phone</h4>
            <p>
              <a href="tel:+972586897174" data-cursor="disable">
                058-689-7174
              </a>
            </p>
          </div>
          <div className="contact-box">
            <h4>Social</h4>
            {/* TODO: swap in Timor's real profile URLs before this ships publicly */}
            <a
              href="https://github.com"
              target="_blank"
              data-cursor="disable"
              className="contact-social"
            >
              Github <MdArrowOutward />
            </a>
            <a
              href="https://www.linkedin.com"
              target="_blank"
              data-cursor="disable"
              className="contact-social"
            >
              Linkedin <MdArrowOutward />
            </a>
          </div>
          <div className="contact-box">
            <h2>
              Applied AI &amp; <br /> Full-Stack <span>Developer</span>
            </h2>
            <h5>
              <MdCopyright /> 2026 Timor Malul
            </h5>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Contact;
