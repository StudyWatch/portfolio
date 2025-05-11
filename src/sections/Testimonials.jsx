import React from 'react';

const testimonials = [
  {
    name: 'Elraz Hamatzni',
    role: 'Project Collaborator',
    phone: '053-281-2345',
    quote:
      'Working with Timor on multiple frontend projects was inspiring. He brings clarity to complex problems, writes clean code, and always strives for intuitive design. A true team player.',
  },
  {
    name: 'Mazal Misk',
    role: 'Former Employer',
    phone: '054-468-0785',
    quote:
      'Timor is reliable, focused, and a natural problem solver. He consistently exceeded expectations and brought creative energy to our projects. I was always confident in giving him complex tasks.',
  },
];

export default function Testimonials() {
  return (
    <section
      id="testimonials"
      className="px-6 py-28 bg-gradient-to-br from-white via-lightgray to-white dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 text-gray-900 dark:text-gray-100"
    >
      <div className="max-w-6xl mx-auto text-center">
        <h2 className="text-5xl font-extrabold mb-14 bg-gradient-to-r from-cyan-400 to-blue-600 text-transparent bg-clip-text">
          Testimonials
        </h2>
        <div className="grid gap-10 md:grid-cols-2">
          {testimonials.map((item, i) => (
            <div
              key={i}
              className="group bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 p-8 rounded-3xl shadow-xl hover:shadow-2xl transition-transform transform hover:-translate-y-1 hover:scale-[1.02] duration-300"
            >
              <div className="relative">
                <div className="absolute top-0 left-0 w-1 h-full bg-gradient-to-b from-cyan-400 to-blue-500 rounded-r-md"></div>
                <p className="pl-4 italic text-base leading-relaxed text-gray-700 dark:text-gray-300 mb-6">
                  “{item.quote}”
                </p>
              </div>
              <div className="border-t border-gray-300 dark:border-gray-600 pt-4 text-left">
                <h4 className="text-lg font-semibold text-navy dark:text-cyan-300">{item.name}</h4>
                <p className="text-sm text-gray-600 dark:text-gray-400">{item.role}</p>
                <p className="text-sm text-gray-500 dark:text-gray-500">📞 {item.phone}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
