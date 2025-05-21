import React from 'react';
import { useForm, ValidationError } from '@formspree/react';
import {
  FaEnvelope, FaUser, FaCommentDots, FaPaperPlane, FaWhatsapp
} from 'react-icons/fa';

export default function Contact() {
  const [state, handleSubmit] = useForm("manoznqa");

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

        {state.succeeded ? (
          <p className="text-center text-green-500 font-semibold text-lg">✅ Thank you! Your message has been sent successfully.</p>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-6 text-left">
            <div className="relative shadow-sm">
              <FaUser className="absolute top-3 left-3 text-gray-500" />
              <input
                id="name"
                type="text"
                name="name"
                placeholder="Your Name"
                required
                className="w-full pl-10 p-3 border border-gray-300 dark:border-gray-700 rounded-md bg-white dark:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-turquoise"
              />
              <ValidationError prefix="Name" field="name" errors={state.errors} />
            </div>

            <div className="relative shadow-sm">
              <FaEnvelope className="absolute top-3 left-3 text-gray-500" />
              <input
                id="email"
                type="email"
                name="email"
                placeholder="Your Email"
                required
                className="w-full pl-10 p-3 border border-gray-300 dark:border-gray-700 rounded-md bg-white dark:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-turquoise"
              />
              <ValidationError prefix="Email" field="email" errors={state.errors} />
            </div>

            <div className="relative shadow-sm">
              <FaCommentDots className="absolute top-3 left-3 text-gray-500" />
              <textarea
                id="message"
                name="message"
                rows="5"
                placeholder="Your Message"
                required
                className="w-full pl-10 p-3 border border-gray-300 dark:border-gray-700 rounded-md bg-white dark:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-turquoise"
              />
              <ValidationError prefix="Message" field="message" errors={state.errors} />
            </div>

            <button
              type="submit"
              disabled={state.submitting}
              className="w-full bg-navy text-white py-3 rounded-md flex items-center justify-center gap-2 hover:bg-turquoise transition shadow-md"
              title="Send Message"
            >
              <FaPaperPlane />
              {state.submitting ? 'Sending...' : 'Send Message'}
            </button>
          </form>
        )}
      </div>
    </section>
  );
}
