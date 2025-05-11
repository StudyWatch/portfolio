import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  base: '/portfolio/', // לפי שם הריפו שלך ב-GitHub
  plugins: [react()],
});
