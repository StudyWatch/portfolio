import React from 'react';
import { FaDownload } from 'react-icons/fa';

export default function Resume() {
  const education = [
    {
      title: 'BSc in Computer Science',
      school: 'The Open University of Israel',
      period: '2023 – Present',
      details: 'Focus on software systems, Java, C, Assembly, Algorithms, and Data Structures. GPA: 87',
    },
    {
      title: 'Pre-Military Mechina Program',
      school: '2019 – 2020',
      details: 'Cultural committee and financial management',
    },
    {
      title: 'High School Diploma',
      school: 'Midrashiat Noam, 2013–2019',
      details: 'Majors: Math, English, Computer Science (10 units), Physics',
    },
  ];

  const experience = [
    {
      title: 'Security Guard',
      org: 'Bank of Israel, 2023 – Present',
      description: 'Maintaining security protocols, handling real-time response, and personnel safety.',
    },
    {
      title: 'Commander – Combat Intelligence',
      org: 'IDF, 2020 – 2023',
      description: 'Led operations, trained soldiers, managed dynamic field situations with critical decisions.',
    },
    {
      title: 'StudyWatch – Personal Project',
      org: '2024',
      description: 'Built a full-stack web platform using React, Tailwind, Node.js, and PostgreSQL for vocabulary learning from TV series.',
    },
  ];

  return (
    <section className="min-h-screen px-6 py-28 bg-gradient-to-b from-white via-lightgray to-white dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 text-gray-900 dark:text-gray-100">
      <div className="max-w-5xl mx-auto">
        <div className="text-center mb-12">
          <h2 className="text-5xl font-extrabold mb-4 bg-gradient-to-r from-cyan-400 to-blue-600 text-transparent bg-clip-text">Resume</h2>
          <p className="text-gray-600 dark:text-gray-400 text-base">Here’s a quick summary of my background. Download the full version below.</p>
          <a
            href="/CV_TimorMalul.pdf"
            download
            className="mt-6 inline-flex items-center gap-2 bg-navy text-white px-6 py-3 rounded-full hover:bg-turquoise transition text-sm font-medium shadow-md"
          >
            <FaDownload /> Download CV
          </a>
        </div>

        {/* Experience */}
        <div className="mb-20">
          <h3 className="text-3xl font-semibold mb-8 border-b pb-3 border-gray-300 dark:border-gray-600">Experience</h3>
          <div className="space-y-6">
            {experience.map((exp, i) => (
              <div key={i} className="bg-white dark:bg-gray-800 rounded-xl shadow-md p-6">
                <h4 className="text-xl font-semibold text-navy dark:text-cyan-300">{exp.title}</h4>
                <p className="text-sm text-turquoise font-medium mt-1">{exp.org}</p>
                <p className="text-sm mt-2 text-gray-600 dark:text-gray-300">{exp.description}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Education */}
        <div>
          <h3 className="text-3xl font-semibold mb-8 border-b pb-3 border-gray-300 dark:border-gray-600">Education</h3>
          <div className="space-y-6">
            {education.map((edu, i) => (
              <div key={i} className="bg-white dark:bg-gray-800 rounded-xl shadow-md p-6">
                <h4 className="text-xl font-semibold text-navy dark:text-cyan-300">{edu.title}</h4>
                <p className="text-sm text-turquoise font-medium mt-1">{edu.school} {edu.period && `| ${edu.period}`}</p>
                <p className="text-sm mt-2 text-gray-600 dark:text-gray-300">{edu.details}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}