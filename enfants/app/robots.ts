import type { MetadataRoute } from "next";

const siteUrl = "https://victeams.github.io/enfants-deportes-1939-1945";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
      disallow: "/api/",
    },
    sitemap: siteUrl + "/sitemap.xml",
    host: siteUrl,
  };
}
