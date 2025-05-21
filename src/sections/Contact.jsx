import React, { useRef, useState } from 'react';
import emailjs from '@emailjs/browser';
import {
  FaEnvelope, FaUser, FaCommentDots, FaPaperPlane, FaWhatsapp
} from 'react-icons/fa';

export default function Contact() {
  const form = useRef();
  const [sent, setSent] = useState(false);

  const sendEmail = (e) => {
    e.preventDefault();
    emailjs
      emailjs.sendForm(
  'service_zw066nn',               // Service ID
  'template_xxxxxx',              // ❗ עדיין חסר - תכניס כאן את ה-Template ID שלך
  form.current,
  '9hLlwm4Htiwobl1_M'             // Public Key (הועתק מהתמונה)
)

      .then(() => {
        setSent(true);
        form.current.reset();
        setTimeout(() => setSent(false), 5000);
      })
      .catch(() => alert('Something went wrong. Please try again.'));
  };

  return (
    <section id="contact" className="px-6 py-28 bg-gradient-to-b from-white to-lightgray dark:from-gray-900 dark:to-gray-800 text-gray-800 dark:text-gray-100">
      <div className="max-w-xl mx-auto text-center">
        <h2 className="text-5xl font-extrabold mb-6 bg-gradient-to-r from-cyan-400 to-blue-600 text-transparent bg-clip-text">
          Contact Me
        </h2>
        <p className="mb-10 text-gray-600 dark:text-gray-400 text-base">
          Have a question, idea, or opportunity? Let’s connect. You can also reach out directly via WhatsApp.
        </p>

        <a
          href="https://wa.me/972586897174"
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center gap-2 text-white bg-green-500 hover:bg-green-600 px-5 py-3 rounded-full shadow-md transition mb-10"
        >
          <FaWhatsapp /> Message me on WhatsApp
        </a>

        <form ref={form} onSubmit={sendEmail} className="space-y-6 text-left">
          {/* Name */}
          <div className="relative shadow-sm">
            <FaUser className="absolute top-3 left-3 text-gray-500" />
            <input
              type="text"
              name="user_name"
              placeholder="Your Name"
              required
              className="w-full pl-10 p-3 border border-gray-300 dark:border-gray-700 rounded-md bg-white dark:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-turquoise"
            />
          </div>

          {/* Email */}
          <div className="relative shadow-sm">
            <FaEnvelope className="absolute top-3 left-3 text-gray-500" />
            <input
              type="email"
              name="user_email"
              placeholder="Your Email"
              required
              className="w-full pl-10 p-3 border border-gray-300 dark:border-gray-700 rounded-md bg-white dark:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-turquoise"
            />
          </div>

          {/* Message */}
          <div className="relative shadow-sm">
            <FaCommentDots className="absolute top-3 left-3 text-gray-500" />
            <textarea
              name="message"
              rows="5"
              placeholder="Your Message"
              required
              className="w-full pl-10 p-3 border border-gray-300 dark:border-gray-700 rounded-md bg-white dark:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-turquoise"
            />
          </div>

          {/* Submit */}
          <button
            type="submit"
            className="w-full bg-navy text-white py-3 rounded-md flex items-center justify-center gap-2 hover:bg-turquoise transition shadow-md"
            title="Send Message"
          >
            <FaPaperPlane />
            {sent ? 'Message Sent 🎉' : 'Send Message'}
          </button>

          {sent && (
            <p className="text-center text-sm text-green-500 mt-4">
              ✅ Thank you! Your message has been sent successfully.
            </p>
          )}
        </form>
      </div>
    </section>
  );
}
