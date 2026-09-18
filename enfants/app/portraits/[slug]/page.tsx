import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { getPortrait, portraits } from "../../../data/portraits";

type PageProps = {
  params: Promise<{ slug: string }>;
};

export function generateStaticParams() {
  return portraits.map((portrait) => ({ slug: portrait.slug }));
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;
  const portrait = getPortrait(slug);
  if (!portrait) return {};
  return {
    title: portrait.name,
    description: portrait.excerpt,
    alternates: {
      canonical: "/portraits/" + portrait.slug,
    },
    openGraph: {
      title: portrait.name,
      description: portrait.excerpt,
      url: "/portraits/" + portrait.slug,
      images: [{ url: portrait.imageUrl, alt: portrait.imageAlt }],
    },
    twitter: {
      card: "summary_large_image",
      title: portrait.name,
      description: portrait.excerpt,
      images: [portrait.imageUrl],
    },
  };
}

export default async function PortraitPage({ params }: PageProps) {
  const { slug } = await params;
  const portrait = getPortrait(slug);
  if (!portrait) notFound();

  return (
    <main className="portrait-page">
      <Link className="back-link" href="/#portraits">← Retour aux portraits</Link>
      <article>
        <header className="portrait-page__header">
          <figure>
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src={portrait.imageUrl} alt={portrait.imageAlt} />
            <figcaption>
              {portrait.imageCredit}.{" "}
              <a href={portrait.sourceUrl} target="_blank" rel="noreferrer">
                Consulter la notice d’archive
              </a>
            </figcaption>
          </figure>
          <div>
            <p className="eyebrow">Portrait documenté</p>
            <h1>{portrait.name}</h1>
            <p className="portrait-page__dates">
              {portrait.birthDate} · {portrait.ageLabel}
            </p>
            <dl className="facts">
              <div>
                <dt>Naissance</dt>
                <dd>{portrait.birthPlace}</dd>
              </div>
              <div>
                <dt>Déportation</dt>
                <dd>{portrait.camp}</dd>
              </div>
              <div>
                <dt>Destin</dt>
                <dd>{portrait.outcome}</dd>
              </div>
              {portrait.deathDate && (
                <div>
                  <dt>Décès</dt>
                  <dd>{portrait.deathDate}, {portrait.deathPlace}</dd>
                </div>
              )}
            </dl>
          </div>
        </header>
        <div className="portrait-page__story">
          {portrait.biography.map((paragraph) => <p key={paragraph}>{paragraph}</p>)}
        </div>
        <footer className="portrait-page__footer">
          <p>
            Cette fiche est fondée sur une notice d’archive nominative. Les
            éléments incertains ne sont pas présentés comme des faits.
          </p>
          <Link className="button" href="/#hommages">Déposer un hommage</Link>
        </footer>
      </article>
    </main>
  );
}
