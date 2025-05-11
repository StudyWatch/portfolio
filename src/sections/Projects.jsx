import React from 'react';
import { motion } from 'framer-motion';
import { FaExternalLinkAlt, FaGithub } from 'react-icons/fa';
import {
  SiReact, SiTailwindcss, SiNodedotjs,
  SiPostgresql, SiTensorflow, SiShopify, SiGooglemaps
} from 'react-icons/si';

import studywatchImg from '../assets/studywatch-screenshot.png';
import toursImg from '../assets/tours-screenshot.png';
import faucetsImg from '../assets/faucetshop-screenshot.png';

const projects = [
  {
    title: 'StudyWatch',
    image: studywatchImg,
    description:
      'An AI-powered platform that helps learners master vocabulary through TV shows. It features smart word extraction, gamified quizzes, and a multilingual interface.',
    tech: ['React', 'Tailwind CSS', 'Node.js', 'PostgreSQL', 'TensorFlow.js'],
    icons: [SiReact, SiTailwindcss, SiNodedotjs, SiPostgresql, SiTensorflow],
    demo: 'https://studywatch.app',
    github: 'https://github.com/StudyWatch/site',
    insights: 'Built from scratch including UX, AI logic, and backend integration.',
  },
  {
    title: 'Chana Tours',
    image: toursImg,
    description:
      'A heartfelt site for a personal tour guide. Tailored for mobile, it enables visitors to explore cultural tours with ease, personality, and elegance.',
    tech: ['React', 'Tailwind CSS', 'EmailJS', 'Google Maps'],
    icons: [SiReact, SiTailwindcss, SiGooglemaps],
    demo: 'https://chana-tours.vercel.app/#hero',
    github: 'https://github.com/StudyWatch/chanatours',
    insights: 'Created for a real-world client with direct feedback and revisions.',
  },
  {
    title: 'FaucetShop',
    image: faucetsImg,
    description:
      'A modern e-commerce site for premium bathroom accessories. It includes product filtering, a responsive cart modal, and a beautiful, clean layout.',
    tech: ['React', 'Tailwind CSS', 'Context API'],
    icons: [SiReact, SiTailwindcss, SiShopify],
    demo: 'https://faucetshop.vercel.app',
    github: 'https://github.com/StudyWatch/faucetshop',
    insights: 'Focused on state management and user experience in e-commerce flow.',
  },
];

export default function Projects() {
  return (
    <section id="projects" className="relative px-6 py-32 bg-gradient-to-br from-white via-lightgray to-white dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 text-gray-900 dark:text-gray-100">
      <div className="absolute top-0 left-1/2 transform -translate-x-1/2 w-[80%] h-[100%] bg-gradient-to-tr from-cyan-100/20 via-transparent to-blue-100/10 dark:from-cyan-800/10 dark:to-blue-900/5 rounded-full blur-3xl pointer-events-none -z-10"></div>

      <div className="max-w-6xl mx-auto text-center">
        <motion.h2
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-5xl font-extrabold mb-4 bg-gradient-to-r from-cyan-400 to-blue-600 text-transparent bg-clip-text"
        >
          Featured Projects
        </motion.h2>
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="text-lg text-gray-600 dark:text-gray-400 mb-20 max-w-2xl mx-auto"
        >
          Beautiful, performant, real-world apps developed with attention to design and purpose.
        </motion.p>

        <div className="space-y-24">
          {projects.map((proj, idx) => (
            <motion.div
              key={proj.title}
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.7, delay: idx * 0.2 }}
              className={`group md:flex rounded-3xl overflow-hidden bg-white dark:bg-gray-800 shadow-xl hover:shadow-2xl transition duration-500 ${
                idx % 2 === 1 ? 'md:flex-row-reverse' : ''
              }`}
            >
              <div className="md:w-1/2 h-72 md:h-auto overflow-hidden relative">
                <img
                  src={proj.image}
                  alt={`${proj.title} screenshot`}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700 ease-out"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/40 to-transparent opacity-0 group-hover:opacity-100 transition"></div>
              </div>

              <div className="md:w-1/2 p-8 sm:p-12 space-y-6 text-left flex flex-col justify-center">
                <h3 className="text-3xl font-bold text-navy dark:text-cyan-300">{proj.title}</h3>
                <p className="text-base leading-relaxed text-gray-700 dark:text-gray-300">{proj.description}</p>
                <p className="text-sm italic text-gray-500 dark:text-gray-400">{proj.insights}</p>
                <div className="flex flex-wrap gap-2">
                  {proj.tech.map((tech, i) => (
                    <span key={i} className="bg-gray-100 dark:bg-gray-700 text-xs text-gray-800 dark:text-gray-200 px-3 py-1 rounded-full shadow-sm">
                      {tech}
                    </span>
                  ))}
                </div>

                <div className="flex flex-wrap items-center gap-4 pt-2">
                  <a
                    href={proj.demo}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2 text-sm px-5 py-2 bg-gradient-to-r from-navy to-blue-700 text-white rounded-full hover:scale-105 transition"
                  >
                    Live Demo <FaExternalLinkAlt />
                  </a>
                  <a
                    href={proj.github}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2 text-sm px-5 py-2 border border-navy text-navy dark:text-cyan-300 rounded-full hover:bg-navy hover:text-white dark:hover:bg-cyan-500 dark:hover:text-white transition"
                  >
                    GitHub <FaGithub />
                  </a>
                </div>

                <div className="flex gap-4 pt-4 text-2xl text-gray-500 dark:text-gray-300">
                  {proj.icons.map((Icon, i) => (
                    <Icon key={i} title={proj.tech[i]} className="hover:scale-110 hover:text-turquoise transition" />
                  ))}
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
