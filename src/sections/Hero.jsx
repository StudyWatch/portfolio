import React from 'react';
import { motion } from 'framer-motion';

export default function Hero() {
  return (
    <section
      id="hero"
      className="relative min-h-screen flex items-center justify-center text-white text-center bg-cover bg-center pt-20 md:pt-28"
      style={{
        backgroundImage: "url('/portfolio/A_digital_illustration_in_a_futuristic_and_technol.png')",
        backgroundColor: "#0b1120", // fallback לצבע כהה
      }}
    >
      {/* שכבת כהות עדינה */}
      <div className="absolute inset-0 bg-gradient-to-b from-black/70 to-navy/90 z-0" />

      {/* תוכן מונפש */}
      <motion.div
        className="relative z-10 max-w-3xl px-4"
        initial={{ opacity: 0, y: 40 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.9, ease: "easeOut" }}
      >
        <h1 className="text-5xl md:text-6xl font-extrabold tracking-tight mb-6 bg-gradient-to-r from-teal-300 to-cyan-500 text-transparent bg-clip-text drop-shadow-lg">
          Building Ideas Into Interfaces
        </h1>
        <p className="text-xl md:text-2xl mb-4 font-medium text-zinc-100 drop-shadow">
          I'm Timor, a frontend developer blending design, logic, and AI.
        </p>
        <p className="max-w-2xl mx-auto text-lg text-zinc-300 leading-relaxed">
          I create smart and engaging user experiences. With a background in CS and a passion for intuitive design,
          I’m here to craft products people love to use.
        </p>
        <div className="mt-10 flex justify-center flex-wrap gap-4">
          <a
            href="#projects"
            className="px-6 py-3 bg-white text-navy font-semibold rounded-full shadow hover:bg-gray-200 transition"
          >
            Explore My Work
          </a>
          <a
            href="#contact"
            className="px-6 py-3 border border-white text-white rounded-full hover:bg-white hover:text-navy transition"
          >
            Contact Me
          </a>
        </div>
      </motion.div>
    </section>
  );
}
