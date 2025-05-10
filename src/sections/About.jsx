import React from 'react';
import { FaLaptopCode, FaGraduationCap, FaShieldAlt, FaUserCheck } from 'react-icons/fa';

export default function About() {
  const highlights = [
    {
      title: 'Strong Development Background',
      description: 'Created StudyWatch – an English-learning web platform with games, AI tools and a smooth UX.',
      icon: <FaLaptopCode className="text-navy text-3xl" />,
    },
    {
      title: 'Computer Science Student',
      description: 'Second-year CS student at The Open University, excelling in data structures, algorithms, C, Java and Assembly.',
      icon: <FaGraduationCap className="text-turquoise text-3xl" />,
    },
    {
      title: 'Leadership Under Pressure',
      description: 'Commanded units in the IDF Intelligence Corps while managing real-time field operations and sensitive data.',
      icon: <FaShieldAlt className="text-yellow-500 text-3xl" />,
    },
    {
      title: 'Self-Motivated & Adaptive',
      description: 'Started CS studies during active military service. Thrives under pressure and adapts fast to new challenges.',
      icon: <FaUserCheck className="text-blue-500 text-3xl" />,
    },
  ];

  return (
    <section id="about" className="px-6 py-24 bg-lightgray dark:bg-gray-900 text-gray-800 dark:text-gray-100">
      <div className="max-w-6xl mx-auto text-center">
        <h2 className="text-4xl font-bold mb-6">About Me</h2>
        <p className="text-lg text-gray-600 dark:text-gray-400 max-w-3xl mx-auto mb-12">
          I'm <strong>Timor Malul</strong>, a second-year Computer Science student and former IDF combat commander. I’m passionate about turning ideas into real, impactful software. With hands-on experience building my own learning platform and a deep love for problem solving, I bring a unique mix of technical depth and leadership.
        </p>

        <div className="grid gap-8 sm:grid-cols-2 md:grid-cols-4">
          {highlights.map((item, i) => (
            <div key={i} className="bg-white dark:bg-gray-800 p-6 rounded-xl shadow hover:shadow-xl transition text-center">
              <div className="flex justify-center mb-3">{item.icon}</div>
              <h3 className="text-xl font-semibold mb-1">{item.title}</h3>
              <p className="text-sm text-gray-700 dark:text-gray-300 leading-relaxed">{item.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
