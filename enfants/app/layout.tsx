import type { Metadata } from "next";
import Link from "next/link";
import "./globals.css";

const title = "Enfants déportés 1939-1945";
const description =
  "Un mémorial numérique consacré aux enfants déportés pendant la Seconde Guerre mondiale, à leurs visages, leurs familles et leurs histoires.";
const siteUrl = "https://memoiredesdeportes.fr/enfants";
const companionSiteUrl =
  "https://victeams.github.io/Le-panthon-des-heros-aushwist-41-45/";

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  verification: {
    google: "Ps2YA3umzm7WkI3vXbghKUg9ybi9iYKRJ7PONsI-8vU",
  },
  title: {
    default: title,
    template: "%s · " + title,
  },
  description,
  alternates: {
    canonical: "/",
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-image-preview": "large",
      "max-snippet": -1,
      "max-video-preview": -1,
    },
  },
  openGraph: {
    title,
    description,
    type: "website",
    locale: "fr_FR",
    url: siteUrl,
    siteName: title,
    images: [
      {
        url: "/social-card.jpg",
        width: 1200,
        height: 628,
        alt: "Enfants déportés 1939-1945 — Leurs visages. Leurs histoires. Notre mémoire.",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title,
    description,
    images: ["/social-card.jpg"],
  },
  icons: {
    icon: "/favicon.svg",
    shortcut: "/favicon.svg",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="fr">
      <body>
        <a className="skip-link" href="#contenu">
          Aller au contenu
        </a>
        <header className="site-header">
          <Link className="site-brand" href="/" aria-label="Accueil du mémorial">
            <span className="site-brand__mark" aria-hidden="true">✦</span>
            <span>Enfants déportés</span>
          </Link>
          <nav aria-label="Navigation principale">
            <Link href="/#portraits">Portraits</Link>
            <Link href="/familles">Familles</Link>
            <Link href="/galerie">Galerie</Link>
            <Link href="/#comprendre">Comprendre</Link>
            <Link href="/#hommages">Hommages</Link>
            <a
              className="site-switch"
              href={companionSiteUrl}
              target="_blank"
              rel="noreferrer"
            >
              Panthéon des héros <span aria-hidden="true">↗</span>
            </a>
          </nav>
        </header>
        <div id="contenu">{children}</div>
        <footer className="site-footer">
          <div className="site-footer__brand" aria-label="Tourisme Territoire Nord-Picardie">
            <div className="site-footer__brand-mark" aria-hidden="true">
              <svg viewBox="0 0 260 220" role="img" aria-hidden="true">
                <path d="M104 30L172 90L148 112L104 62L80 94L57 77L104 30Z" fill="none" stroke="currentColor" strokeWidth="8" strokeLinejoin="round"/>
                <path d="M39 120L118 46L164 100L124 142L87 116L50 149L39 120Z" fill="none" stroke="currentColor" strokeWidth="8" strokeLinejoin="round"/>
                <path d="M110 112L202 24L210 41L148 112L110 112Z" fill="none" stroke="currentColor" strokeWidth="8" strokeLinejoin="round"/>
                <path d="M126 118L190 157L156 192L116 158L126 118Z" fill="none" stroke="currentColor" strokeWidth="8" strokeLinejoin="round"/>
                <path d="M97 172L87 208C105 194 122 190 146 188C156 183 163 177 176 169" fill="none" stroke="currentColor" strokeWidth="6" strokeLinecap="round"/>
                <path d="M200 156C222 156 231 171 233 188C211 180 199 174 187 163" fill="none" stroke="currentColor" strokeWidth="6" strokeLinecap="round"/>
              </svg>
            </div>
            <div className="site-footer__brand-copy">
              <div className="site-footer__wordmark" aria-label="Tourisme Territoire Nord-Picardie">
                <span className="site-footer__tourisme">Tourisme</span>
                <span className="site-footer__territoire">Territoire</span>
                <span className="site-footer__region">Nord-Picardie</span>
              </div>
              <div className="site-footer__location">Doullens • Somme</div>
              <div className="site-footer__tagline">“Ressourcez-vous entre nature et patrimoine”</div>
            </div>
          </div>
          <div className="site-footer__meta">
            <p>Enfants déportés 1939-1945 · Mémoire, documentation, transmission.</p>
            <p>
              <a href={companionSiteUrl}>Le Panthéon des héros</a>
              <span aria-hidden="true"> · </span>
              Aucune publicité. Aucun profilage publicitaire.
            </p>
          </div>
        </footer>
      </body>
    </html>
  );
}
