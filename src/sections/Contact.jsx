import React, { useState } from "react";

export default function Contact() {
  const [sent, setSent] = useState(false);

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
          💬 Message me on WhatsApp
        </a>

        {sent ? (
          <p className="text-green-500 text-lg font-semibold">✅ Message sent successfully!</p>
        ) : (
          <form
            action="https://formspree.io/f/manoznqa"
            method="POST"
            onSubmit={() => setSent(true)}
            className="space-y-6 text-left"
          >
            <input type="hidden" name="_captcha" value="false" />

            <div className="relative shadow-sm">
              <input
                type="text"
                name="name"
                placeholder="Your Name"
                required
                className="w-full p-3 pl-4 border border-gray-300 dark:border-gray-700 rounded-md bg-white dark:bg-gray-800"
              />
            </div>

            <div className="relative shadow-sm">
              <input
                type="email"
                name="email"
                placeholder="Your Email"
                required
                className="w-full p-3 pl-4 border border-gray-300 dark:border-gray-700 rounded-md bg-white dark:bg-gray-800"
              />
            </div>

            <div className="relative shadow-sm">
              <textarea
                name="message"
                rows={5}
                placeholder="Your Message"
                required
                className="w-full p-3 pl-4 border border-gray-300 dark:border-gray-700 rounded-md bg-white dark:bg-gray-800"
              />
            </div>

            <button
              type="submit"
              className="w-full bg-navy text-white py-3 rounded-md flex items-center justify-center gap-2 hover:bg-turquoise transition shadow-md"
            >
              📧 Send Message
            </button>
          </form>
        )}
      </div>
    </section>
  );
}
