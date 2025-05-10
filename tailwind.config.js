/** @type {import('tailwindcss').Config} */
export default {
    content: ['./index.html', './src/**/*.{js,jsx,ts,tsx}'],
    darkMode: 'class',
    theme: {
      extend: {
        colors: {
          navy: '#0a192f',
          turquoise: '#2dd4bf',
          lightgray: '#f3f4f6',
          darkbg: '#0f172a',
          accent: '#38bdf8',
          highlight: '#e0f2fe',
          muted: '#64748b',
          surface: '#1e293b',
          background: '#f8fafc',
        },
        fontFamily: {
          sans: ['Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
        },
        boxShadow: {
          soft: '0 2px 8px rgba(0, 0, 0, 0.1)',
          glow: '0 0 8px rgba(45, 212, 191, 0.5)',
          card: '0 6px 20px rgba(0,0,0,0.08)',
          inner: 'inset 0 1px 2px rgba(0, 0, 0, 0.1)',
        },
        transitionTimingFunction: {
          'in-out-soft': 'cubic-bezier(0.4, 0, 0.2, 1)',
        },
        spacing: {
          'section': '6rem',
          'nav-height': '4.5rem',
        },
        zIndex: {
          'nav': 50,
          'modal': 60,
        },
        borderRadius: {
          xl: '1rem',
          '2xl': '1.5rem',
        },
        typography: (theme) => ({
          dark: {
            css: {
              color: theme('colors.gray.300'),
              a: { color: theme('colors.turquoise') },
              h1: { color: theme('colors.white') },
              h2: { color: theme('colors.white') },
              strong: { color: theme('colors.white') },
              code: { color: theme('colors.turquoise') },
            },
          },
        }),
      },
    },
    plugins: [
      require('@tailwindcss/forms'),
      require('@tailwindcss/typography'),
    ],
  };
  