import { defineConfig } from 'vite';

export default defineConfig({
  server: {
    port: 5173,
    strictPort: true,
    proxy: {
      '/demo_message': 'http://localhost:8443',
    },
  },
});
