import React from 'react';
import { FaDownload, FaCheckCircle } from 'react-icons/fa';

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
    <section className="px-6 py-24 bg-white dark:bg-gray-900 text-gray-800 dark:text-gray-100">
      <div className="max-w-5xl mx-auto">
        <div className="text-center mb-10">
          <h2 className="text-4xl font-bold mb-4">Resume</h2>
          <p className="text-gray-600 dark:text-gray-400">Here’s a quick summary of my background. Download the full version below.</p>
          <a
            href="/CV_TimorMalul.pdf"
            download
            className="mt-4 inline-flex items-center gap-2 bg-navy text-white px-5 py-3 rounded-full hover:bg-turquoise transition text-sm font-medium shadow-md"
          >
            <FaDownload /> Download CV
          </a>
        </div>

        {/* Experience */}
        <div className="mb-16">
          <h3 className="text-2xl font-semibold mb-6 border-b pb-2">Experience</h3>
          {experience.map((exp, i) => (
            <div key={i} className="mb-6">
              <h4 className="text-lg font-semibold">{exp.title}</h4>
              <p className="text-sm text-turquoise font-medium">{exp.org}</p>
              <p className="text-sm mt-1 text-gray-600 dark:text-gray-300">{exp.description}</p>
            </div>
          ))}
        </div>

        {/* Education */}
        <div>
          <h3 className="text-2xl font-semibold mb-6 border-b pb-2">Education</h3>
          {education.map((edu, i) => (
            <div key={i} className="mb-6">
              <h4 className="text-lg font-semibold">{edu.title}</h4>
              <p className="text-sm text-turquoise font-medium">{edu.school} {edu.period && `| ${edu.period}`}</p>
              <p className="text-sm mt-1 text-gray-600 dark:text-gray-300">{edu.details}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
