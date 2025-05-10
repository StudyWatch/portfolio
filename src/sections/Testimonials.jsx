import React from 'react';

const testimonials = [
  {
    name: 'Prof. Shira Rosen',
    role: 'CS Professor, Open University',
    quote: 'Timor is one of the most dedicated students I’ve had. His curiosity and problem-solving skills are outstanding.',
    avatar: '/avatars/shira.png',
  },
  {
    name: 'Yossi Cohen',
    role: 'High School CS Teacher',
    quote: 'Already in high school, Timor was helping classmates and creating advanced projects far beyond his level.',
    avatar: '/avatars/yossi.png',
  },
  {
    name: 'Tali Ben-David',
    role: 'EdTech Team Lead',
    quote: 'Timor brought UX innovations and strong frontend structure to our product. I’d hire him again in a heartbeat.',
    avatar: '/avatars/tali.png',
  },
];

export default function Testimonials() {
  return (
    <section id="testimonials" className="px-6 py-24 bg-white dark:bg-gray-900 text-gray-800 dark:text-gray-100">
      <div className="max-w-6xl mx-auto text-center">
        <h2 className="text-4xl font-bold mb-12">What People Say</h2>
        <div className="grid gap-8 md:grid-cols-3">
          {testimonials.map((item, i) => (
            <div
              key={i}
              className="bg-lightgray dark:bg-gray-800 p-6 rounded-xl shadow-md hover:shadow-xl transition transform hover:-translate-y-1"
            >
              <div className="flex justify-center mb-4">
                <img
                  src={item.avatar}
                  alt={item.name}
                  className="w-16 h-16 rounded-full object-cover shadow"
                />
              </div>
              <p className="italic text-sm mb-4 text-gray-700 dark:text-gray-300">
                “{item.quote}”
              </p>
              <h4 className="font-semibold">{item.name}</h4>
              <p className="text-sm text-muted dark:text-gray-400">{item.role}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
