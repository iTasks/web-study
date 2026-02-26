# Build Tools

[← Back to Phase 2](README.md) | [Roadmap](../README.md)

## Vite (Modern — Recommended)

Vite uses native ES modules during development (instant HMR) and Rollup for production builds.

```bash
# New project
npm create vite@latest my-app -- --template react-ts

# Structure
my-app/
├── index.html          # entry point (not in src/)
├── vite.config.ts
├── tsconfig.json
├── src/
│   ├── main.tsx        # app bootstrap
│   └── App.tsx
└── public/             # static assets (served at /)
```

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),  // import from '@/components/...'
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        // Manual chunk splitting — improves caching
        manualChunks: {
          react: ['react', 'react-dom'],
          router: ['react-router-dom'],
          query: ['@tanstack/react-query'],
        },
      },
    },
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:8000',  // Python backend
        changeOrigin: true,
      },
    },
  },
});
```

### Environment Variables

```bash
# .env.development
VITE_API_URL=http://localhost:8000
VITE_AUTH_DOMAIN=dev.auth.example.com

# .env.production
VITE_API_URL=https://api.example.com
VITE_AUTH_DOMAIN=auth.example.com
```

```typescript
// Access in code (typed)
const apiUrl = import.meta.env.VITE_API_URL;

// Type declaration
interface ImportMetaEnv {
  readonly VITE_API_URL: string;
  readonly VITE_AUTH_DOMAIN: string;
}
```

---

## ESLint

Static analysis — catches bugs and enforces style.

```bash
npm install -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin eslint-plugin-react eslint-plugin-react-hooks
```

```json
// .eslintrc.json
{
  "parser": "@typescript-eslint/parser",
  "parserOptions": { "project": "./tsconfig.json" },
  "plugins": ["@typescript-eslint", "react-hooks"],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended-type-checked",
    "plugin:react-hooks/recommended"
  ],
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-floating-promises": "error",
    "react-hooks/exhaustive-deps": "error",
    "no-console": ["warn", { "allow": ["warn", "error"] }]
  }
}
```

---

## Prettier

Opinionated code formatter — no style debates in code review.

```bash
npm install -D prettier eslint-config-prettier
```

```json
// .prettierrc
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2
}
```

```json
// package.json scripts
{
  "scripts": {
    "lint": "eslint src --ext .ts,.tsx",
    "lint:fix": "eslint src --ext .ts,.tsx --fix",
    "format": "prettier --write src",
    "format:check": "prettier --check src",
    "type-check": "tsc --noEmit"
  }
}
```

---

## Webpack Basics

Understanding Webpack is useful when maintaining legacy projects or customizing CRA.

```javascript
// webpack.config.js (simplified)
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: './src/index.tsx',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: '[name].[contenthash].js',  // content hash for cache busting
    clean: true,
  },
  resolve: {
    extensions: ['.tsx', '.ts', '.js'],
  },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: 'ts-loader',
        exclude: /node_modules/,
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({ template: './public/index.html' }),
  ],
  optimization: {
    splitChunks: {
      chunks: 'all',   // code splitting
    },
  },
};
```

---

## CDN-Friendly Production Builds

For CDN deployment, assets need content-hash filenames and proper cache headers.

```typescript
// vite.config.ts — CDN-optimized output
export default defineConfig({
  base: 'https://cdn.example.com/app/',   // CDN base URL
  build: {
    assetsDir: 'assets',
    rollupOptions: {
      output: {
        // Hashed filenames → long cache TTL on CDN
        entryFileNames: 'assets/[name].[hash].js',
        chunkFileNames: 'assets/[name].[hash].js',
        assetFileNames: 'assets/[name].[hash][extname]',
      },
    },
  },
});
```

```nginx
# nginx config for serving from CDN origin
location /assets/ {
    add_header Cache-Control "public, max-age=31536000, immutable";
}
location / {
    add_header Cache-Control "no-cache";
    try_files $uri /index.html;
}
```

---

## Resources

- [Vite Documentation](https://vitejs.dev/guide/)
- [ESLint TypeScript](https://typescript-eslint.io/)
- [Prettier](https://prettier.io/docs/en/index.html)

---

→ [Phase 2 Overview](README.md) | [Phase 3 – React Native](../phase-3-react-native/README.md)
