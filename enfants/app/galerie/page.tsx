import type { Metadata } from "next";
import Link from "next/link";
import { portraits } from "../../data/portraits";

export const metadata: Metadata = {
  title: "Galerie photographique",
  description:
    "Photographies d’archives documentées d’enfants déportés entre 1939 et 1945.",
  alternates: {
    canonical: "/galerie",
  },
};

export default function GalleryPage() {
  return (
    <main className="gallery-page">
      <header className="gallery-page__header">
        <div>
          <p className="eyebrow">Photographies d’archives</p>
          <h1>Galerie</h1>
        </div>
        <p>
          Chaque image est présentée sans recadrage ni modification. Sa légende
          indique l’institution ou la collection qui la conserve.
        </p>
      </header>

      <div className="gallery-grid">
        {portraits.map((portrait) => (
          <figure key={portrait.slug} className="gallery-item">
            <Link href={"/portraits/" + portrait.slug}>
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={portrait.imageUrl} alt={portrait.imageAlt} loading="lazy" />
            </Link>
            <figcaption>
              <strong>{portrait.name}</strong>
              <span>{portrait.birthDate} · {portrait.birthPlace}</span>
              <span>{portrait.imageCredit}</span>
              <a href={portrait.sourceUrl} target="_blank" rel="noreferrer">
                Notice d’archive ↗
              </a>
            </figcaption>
          </figure>
        ))}
      </div>
    </main>
  );
}
