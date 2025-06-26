import React from 'react';
import {
  FaJsSquare, FaHtml5, FaCss3Alt, FaGitAlt, FaUsers, FaClock, FaBrain,
  FaNodeJs, FaCloud
} from 'react-icons/fa';
import {
  SiReact, SiTailwindcss, SiPostgresql, SiTypescript, SiSupabase
} from 'react-icons/si';

export default function Skills() {
  const skills = [
    { name: 'React', icon: <SiReact className="text-sky-500 text-4xl" /> },
    { name: 'Tailwind CSS', icon: <SiTailwindcss className="text-cyan-400 text-4xl" /> },
    { name: 'JavaScript', icon: <FaJsSquare className="text-yellow-300 text-4xl" /> },
    { name: 'TypeScript', icon: <SiTypescript className="text-blue-600 text-4xl" /> }, // אם לא השתמשת, תמחק שורה זו
    { name: 'Node.js', icon: <FaNodeJs className="text-green-700 text-4xl" /> },       // אם לא השתמשת, תמחק שורה זו
    { name: 'Supabase', icon: <SiSupabase className="text-green-500 text-4xl" /> },
    { name: 'PostgreSQL', icon: <SiPostgresql className="text-blue-700 text-4xl" /> },
    { name: 'HTML5', icon: <FaHtml5 className="text-orange-600 text-4xl" /> },
    { name: 'CSS3', icon: <FaCss3Alt className="text-blue-600 text-4xl" /> },
    { name: 'Git & GitHub', icon: <FaGitAlt className="text-orange-500 text-4xl" /> },
    { name: 'ExcelJS', icon: <FaCloud className="text-blue-400 text-4xl" /> },        // ייצוא לאקסל (אם רלוונטי)
    { name: 'EmailJS', icon: <FaCloud className="text-cyan-300 text-4xl" /> },        // יצירת קשר (אם רלוונטי)
    { name: 'Problem Solving', icon: <FaBrain className="text-purple-600 text-4xl" /> },
    { name: 'Teamwork', icon: <FaUsers className="text-green-600 text-4xl" /> },
    { name: 'Time Management', icon: <FaClock className="text-indigo-400 text-4xl" /> },
  ];

  return (
    <section id="skills" className="px-6 py-24 bg-gradient-to-b from-white to-lightgray dark:from-gray-900 dark:to-gray-800 text-gray-800 dark:text-gray-100">
      <div className="max-w-7xl mx-auto text-center">
        <h2 className="text-4xl font-extrabold mb-6">Skills & Technologies</h2>
        <p className="text-lg text-gray-600 dark:text-gray-400 max-w-3xl mx-auto mb-12">
          Building modern fullstack apps with <span className="font-bold text-navy">React</span>, <span className="font-bold text-turquoise">Supabase</span>, RESTful APIs, and a clean cloud workflow.<br />
          All my recent projects are based on scalable <span className="font-bold text-navy">frontend</span> and <span className="font-bold text-navy">backend</span> stacks, real DB logic, and best practices in UI/UX.
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
