import React, { useState } from 'react';
import { FaSun, FaMoon, FaBars, FaTimes } from 'react-icons/fa';
import { HashLink } from 'react-router-hash-link';
import { Link } from 'react-router-dom';

export default function Navbar({ toggleDarkMode, darkMode }) {
  const [menuOpen, setMenuOpen] = useState(false);

  const navLinks = [
    { label: 'About', href: '/#about' },
    { label: 'Skills', href: '/#skills' },
    { label: 'Projects', href: '/#projects' },
    { label: 'Testimonials', href: '/#testimonials' },
    { label: 'Contact', href: '/#contact' },
  ];

  return (
    <nav className="fixed top-0 left-0 w-full z-50 bg-white/80 dark:bg-gray-900/80 backdrop-blur-md shadow-md transition">
      <div className="max-w-7xl mx-auto px-6 py-4 flex justify-between items-center">
        {/* לוגו */}
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
          <Link to="/">
            Timor<span className="text-turquoise">.Dev</span>
          </Link>
        </h1>

        {/* ניווט בדסקטופ */}
        <div className="hidden md:flex items-center space-x-8 font-medium text-gray-800 dark:text-gray-100">
          {navLinks.map((link) => (
            <HashLink
              key={link.href}
              smooth
              to={link.href}
              className="hover:text-turquoise transition"
            >
              {link.label}
            </HashLink>
          ))}

          {/* קישור לרזומה */}
          <Link to="/resume" className="hover:text-turquoise transition">
            Resume
          </Link>
        </div>

        {/* מצב כהה + כפתור תפריט */}
        <div className="flex items-center space-x-4">
          <button
            onClick={toggleDarkMode}
            className="text-xl p-2 rounded-full bg-gray-200 dark:bg-gray-700 transition"
            title="Toggle dark mode"
          >
            {darkMode ? <FaSun className="text-yellow-400" /> : <FaMoon className="text-blue-300" />}
          </button>

          <button
            className="md:hidden text-2xl"
            onClick={() => setMenuOpen(!menuOpen)}
            aria-label="Toggle menu"
          >
            {menuOpen ? <FaTimes /> : <FaBars />}
          </button>
        </div>
      </div>

      {/* תפריט נייד */}
      {menuOpen && (
        <div className="md:hidden bg-white dark:bg-gray-900 text-center py-6 shadow-inner">
          <ul className="space-y-4 text-lg font-medium">
            {navLinks.map((link) => (
              <li key={link.href}>
                <HashLink
                  smooth
                  to={link.href}
                  onClick={() => setMenuOpen(false)}
                  className="text-gray-800 dark:text-gray-200 hover:text-turquoise transition"
                >
                  {link.label}
                </HashLink>
              </li>
            ))}
            <li>
              <Link
                to="/resume"
                onClick={() => setMenuOpen(false)}
                className="text-gray-800 dark:text-gray-200 hover:text-turquoise transition"
              >
                Resume
              </Link>
            </li>
          </ul>
        </div>
      )}
    </nav>
  );
}
