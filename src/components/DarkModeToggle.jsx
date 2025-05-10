import React from 'react';

export default function DarkModeToggle({ darkMode, toggleDarkMode }) {
  return (
    <button
      onClick={toggleDarkMode}
      className="ml-4 text-xl p-2 rounded-full bg-gray-200 dark:bg-gray-700 hover:scale-110 transition"
      title="Toggle dark mode"
      aria-label="Toggle dark mode"
    >
      {darkMode ? '🌞' : '🌙'}
    </button>
  );
}
