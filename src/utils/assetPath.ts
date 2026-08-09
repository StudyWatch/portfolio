// Resolves a public-folder asset against Vite's configured base path, so
// references keep working when the site isn't hosted at domain root (e.g.
// GitHub Pages serving from /portfolio/). Accepts the path with or without
// a leading slash.
export function assetPath(path: string): string {
  return `${import.meta.env.BASE_URL}${path.replace(/^\/+/, "")}`;
}
