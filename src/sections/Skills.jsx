import React from 'react';
import {
  FaJava, FaPython, FaJsSquare, FaHtml5, FaCss3Alt,
  FaGitAlt, FaUsers, FaClock, FaBrain, FaCogs
} from 'react-icons/fa';
import {
  SiPostgresql, SiLinux, SiJirasoftware, SiConfluence, SiC as SiCLang, SiAssemblyscript
} from 'react-icons/si';

export default function Skills() {
  const skills = [
    { name: 'Java', icon: <FaJava className="text-red-500 text-4xl" /> },
    { name: 'Python', icon: <FaPython className="text-yellow-400 text-4xl" /> },
    { name: 'C', icon: <SiCLang className="text-blue-500 text-4xl" /> },
    { name: 'Assembly', icon: <SiAssemblyscript className="text-gray-500 text-4xl" /> },
    { name: 'JavaScript', icon: <FaJsSquare className="text-yellow-300 text-4xl" /> },
    { name: 'HTML5', icon: <FaHtml5 className="text-orange-600 text-4xl" /> },
    { name: 'CSS3', icon: <FaCss3Alt className="text-blue-600 text-4xl" /> },
    { name: 'SQL / PostgreSQL', icon: <SiPostgresql className="text-blue-700 text-4xl" /> },
    { name: 'Git & GitHub', icon: <FaGitAlt className="text-orange-500 text-4xl" /> },
    { name: 'Linux', icon: <SiLinux className="text-gray-400 text-4xl" /> },
    { name: 'JIRA', icon: <SiJirasoftware className="text-blue-500 text-4xl" /> },
    { name: 'Confluence', icon: <SiConfluence className="text-blue-300 text-4xl" /> },
    { name: 'Problem Solving', icon: <FaBrain className="text-purple-600 text-4xl" /> },
    { name: 'Teamwork', icon: <FaUsers className="text-green-600 text-4xl" /> },
    { name: 'Time Management', icon: <FaClock className="text-indigo-400 text-4xl" /> },
  ];

  return (
    <section id="skills" className="px-6 py-24 bg-gradient-to-b from-white to-lightgray dark:from-gray-900 dark:to-gray-800 text-gray-800 dark:text-gray-100">
      <div className="max-w-7xl mx-auto text-center">
        <h2 className="text-4xl font-extrabold mb-6">Skills & Technologies</h2>
        <p className="text-lg text-gray-600 dark:text-gray-400 max-w-3xl mx-auto mb-12">
          These are the tools and languages I work with daily to build responsive, scalable, and user-centric software. My focus is on clean code, fast learning, and impactful delivery.
        </p>
        <div className="grid gap-6 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
          {skills.map((skill, i) => (
            <div key={i} className="bg-white dark:bg-gray-800 p-6 rounded-xl shadow hover:shadow-2xl transform hover:-translate-y-1 transition text-center">
              <div className="flex justify-center mb-3">{skill.icon}</div>
              <h3 className="text-lg font-semibold">{skill.name}</h3>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
