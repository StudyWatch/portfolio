import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaExternalLinkAlt, FaGithub, FaChevronLeft, FaChevronRight } from 'react-icons/fa';
import {
  SiReact, SiTailwindcss, SiNodedotjs,
  SiPostgresql, SiTensorflow, SiShopify, SiGooglemaps
} from 'react-icons/si';

import faucetsImg from '../assets/faucetshop-screenshot.png';
import toursImg from '../assets/tours-screenshot.png';
import smartpackingImg1 from '../assets/smartpacking-screenshot.png';
import smartpackingImg2 from '../assets/smartpacking-2.png';
import schedulerImg1 from '../assets/scheduler-screenshot.png';
import schedulerImg2 from '../assets/scheduler-2.png';
import studywatchImg1 from '../assets/studywatch-1.png';
import studywatchImg2 from '../assets/studywatch-2.png';
import studywatchImg3 from '../assets/studywatch-3.png';
import studywatchImg4 from '../assets/studywatch-4.png';
import studywatchImg5 from '../assets/studywatch-5.png';

const projects = [
  {
    title: 'StudyWatch',
    images: [studywatchImg1, studywatchImg2, studywatchImg3, studywatchImg4, studywatchImg5],
    description: 'An AI-powered platform to master vocabulary through TV shows with gamified learning.',
    tech: ['React', 'Tailwind CSS', 'Node.js', 'PostgreSQL', 'TensorFlow.js'],
    icons: [SiReact, SiTailwindcss, SiNodedotjs, SiPostgresql, SiTensorflow],
    demo: 'https://studywatch-swart.vercel.app/',
    github: 'https://github.com/StudyWatch/studywatch',
    insights: 'Built with AI word extraction, custom backend logic, and multilingual support.',
  },
  {
    title: 'SmartPacking',
    images: [smartpackingImg1, smartpackingImg2],
    description: 'A smart packing checklist app that generates personal lists for trips.',
    tech: ['React', 'Tailwind CSS', 'Supabase', 'Zustand', 'LocalStorage'],
    icons: [SiReact, SiTailwindcss, SiPostgresql],
    demo: 'https://smartpacking.vercel.app',
    github: 'https://github.com/StudyWatch/smartpacking',
    insights: 'Fast and intuitive packing assistant with realtime logic.',
  },
  {
    title: 'Shift Scheduler',
    images: [schedulerImg1, schedulerImg2],
    description: 'Smart employee shift scheduler with constraints, rules, and export features.',
    tech: ['React', 'Tailwind CSS', 'Supabase', 'TypeScript', 'ExcelJS'],
    icons: [SiReact, SiTailwindcss, SiPostgresql],
    demo: 'https://bois-beta.vercel.app/',
    github: 'https://github.com/StudyWatch/shift-scheduler',
    insights: 'Built to manage complex real-world scheduling needs.',
  },
  {
    title: 'Chana Tours',
    images: [toursImg],
    description: 'A mobile-friendly personal tour guide site built with style and simplicity.',
    tech: ['React', 'Tailwind CSS', 'EmailJS', 'Google Maps'],
    icons: [SiReact, SiTailwindcss, SiGooglemaps],
    demo: 'https://chana-tours.vercel.app/#hero',
    github: 'https://github.com/StudyWatch/Chana-tours',
    insights: 'Designed for a real client, optimized for conversion.',
  },
  {
    title: 'FaucetShop',
    images: [faucetsImg],
    description: 'Elegant online store for premium bathroom accessories with cart and filter system.',
    tech: ['React', 'Tailwind CSS', 'Context API'],
    icons: [SiReact, SiTailwindcss, SiShopify],
    demo: 'https://faucet-shop-ngpl.vercel.app',
    github: 'https://github.com/StudyWatch/faucet-shop',
    insights: 'Polished user experience with state management flow.',
  },
];

export default function Projects() {
  const [currentSlides, setCurrentSlides] = useState(projects.map(() => 0));
  const [imgKey, setImgKey] = useState(projects.map(() => 0));

  const goToSlide = (idx, dir) => {
    setCurrentSlides(prev => {
      const total = projects[idx].images.length;
      const next = (prev[idx] + dir + total) % total;
      const updated = [...prev];
      updated[idx] = next;
      setImgKey(keys => {
        const newKeys = [...keys];
        newKeys[idx] = Math.random();
        return newKeys;
      });
      return updated;
    });
  };

  return (
    <section id="projects" className="relative px-6 py-32 bg-gradient-to-br from-white via-lightgray to-white dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 text-gray-900 dark:text-gray-100">
      <div className="max-w-6xl mx-auto text-center">
        <motion.h2
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="text-5xl font-extrabold mb-4 bg-gradient-to-r from-cyan-400 to-blue-600 text-transparent bg-clip-text"
        >
          Featured Projects
        </motion.h2>
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="text-lg text-gray-600 dark:text-gray-400 mb-20 max-w-2xl mx-auto"
        >
          Beautiful, performant, real-world apps developed with attention to design and purpose.
        </motion.p>

        <div className="space-y-24">
          {projects.map((proj, idx) => {
            const currentImg = proj.images[currentSlides[idx]];
            return (
              <motion.div
                key={proj.title}
                initial={{ opacity: 0, y: 50 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.7, delay: idx * 0.2 }}
                className={`group md:flex rounded-3xl overflow-hidden bg-white dark:bg-gray-800 shadow-xl hover:shadow-2xl transition duration-500 ${
                  idx % 2 === 1 ? 'md:flex-row-reverse' : ''
                }`}
              >
                <div className="md:w-1/2 h-72 md:h-[400px] relative overflow-hidden flex items-center justify-center bg-gray-100 dark:bg-gray-700">
                  <AnimatePresence mode="wait">
                    <motion.img
                      key={imgKey[idx] + currentSlides[idx]}
                      src={currentImg}
                      alt={`${proj.title} screenshot`}
                      className="w-full h-full object-cover rounded-xl shadow transition"
                      initial={{ opacity: 0, scale: 1.03 }}
                      animate={{ opacity: 1, scale: 1 }}
                      exit={{ opacity: 0, scale: 1.03 }}
                      transition={{ duration: 0.5 }}
                    />
                  </AnimatePresence>
                  {proj.images.length > 1 && (
                    <>
                      <button
                        onClick={() => goToSlide(idx, -1)}
                        className="absolute top-1/2 left-3 transform -translate-y-1/2 bg-black/40 text-white p-2 rounded-full hover:bg-black/60"
                      >
                        <FaChevronLeft />
                      </button>
                      <button
                        onClick={() => goToSlide(idx, 1)}
                        className="absolute top-1/2 right-3 transform -translate-y-1/2 bg-black/40 text-white p-2 rounded-full hover:bg-black/60"
                      >
                        <FaChevronRight />
                      </button>
                      <div className="absolute bottom-3 w-full flex justify-center gap-2">
                        {proj.images.map((_, i) => (
                          <div
                            key={i}
                            className={`w-2 h-2 rounded-full ${
                              currentSlides[idx] === i ? 'bg-white' : 'bg-white/40'
                            }`}
                          ></div>
                        ))}
                      </div>
                    </>
                  )}
                </div>

                <div className="md:w-1/2 p-8 sm:p-12 space-y-6 text-left flex flex-col justify-center">
                  <h3 className="text-3xl font-bold text-navy dark:text-cyan-300">{proj.title}</h3>
                  <p className="text-base text-gray-700 dark:text-gray-300">{proj.description}</p>
                  <p className="text-sm italic text-gray-500 dark:text-gray-400">{proj.insights}</p>

                  <div className="flex flex-wrap gap-2">
                    {proj.tech.map((tech, i) => (
                      <span key={i} className="bg-gray-100 dark:bg-gray-700 text-xs text-gray-800 dark:text-gray-200 px-3 py-1 rounded-full">
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
            );
          })}
        </div>
      </div>
    </section>
  );
}
