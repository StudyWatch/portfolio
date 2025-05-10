import React from 'react';
import { FaLinkedin, FaGithub, FaEnvelope, FaFileDownload } from 'react-icons/fa';

export default function Footer() {
  return (
    <footer className="bg-navy text-gray-400 py-10 px-6">
      <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center gap-8">
        
        {/* טקסט שמאלי */}
        <div className="text-center md:text-left">
          <h3 className="text-xl font-bold text-turquoise mb-2">Timor Malul</h3>
          <p className="text-sm">
            Frontend Developer & CS Student. Passionate about building smart, accessible, and beautiful web apps.
          </p>
        </div>

        {/* אייקונים חברתיים */}
        <div className="flex items-center gap-6 text-2xl">
          <a
            href="https://linkedin.com/in/Timor-Malul"
            target="_blank"
            rel="noopener noreferrer"
            className="hover:text-turquoise transform hover:scale-110 transition"
            aria-label="LinkedIn"
          >
            <FaLinkedin />
          </a>
          <a
            href="https://github.com/yourusername"
            target="_blank"
            rel="noopener noreferrer"
            className="hover:text-turquoise transform hover:scale-110 transition"
            aria-label="GitHub"
          >
            <FaGithub />
          </a>
          <a
            href="mailto:Timor34@gmail.com"
            className="hover:text-turquoise transform hover:scale-110 transition"
            aria-label="Email"
          >
            <FaEnvelope />
          </a>
          <a
            href="/CV_TimorMalul.pdf"
            download
            className="hover:text-turquoise transform hover:scale-110 transition"
            aria-label="Download CV"
          >
            <FaFileDownload />
          </a>
        </div>
      </div>

      {/* שורה תחתונה */}
      <div className="mt-8 text-center text-xs text-gray-500">
        © {new Date().getFullYear()} Timor Malul. All rights reserved.
      </div>
    </footer>
  );
}
