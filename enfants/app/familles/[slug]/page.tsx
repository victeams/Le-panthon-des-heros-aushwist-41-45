import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { families } from "../../../data/families";

export function generateStaticParams() {
  return families.map((family) => ({ slug: family.slug }));
}

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> {
  const { slug } = await params;
  const family = families.find((item) => item.slug === slug);
  if (!family) return {};
  return { title: family.name, description: family.excerpt, alternates: { canonical: `/familles/${family.slug}` } };
}

export default async function FamilyPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const family = families.find((item) => item.slug === slug);
  if (!family) notFound();

  return (
    <main className="family-detail-page">
      <Link className="family-detail-page__back" href="/familles">← Tous les portraits de familles</Link>
      <article className="family-story">
        <header className="family-story__header">
          <figure>
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src={family.imageUrl} alt={family.imageAlt} />
            <figcaption>{family.imageCredit}</figcaption>
          </figure>
          <div>
            <p className="eyebrow">{family.city} · Famille photographiée au complet</p>
            <h1>{family.name}</h1>
            <p className="family-story__lead">{family.excerpt}</p>
            <dl className="family-facts">
              <div><dt>Adresse</dt><dd>{family.address}</dd></div>
              <div><dt>Déportation</dt><dd>{family.deportation}</dd></div>
              <div><dt>Destination</dt><dd>{family.camp}</dd></div>
            </dl>
          </div>
        </header>
        <section className="family-members" aria-label={`Membres de la ${family.name}`}>
          {family.members.map((member) => (
            <div className="family-member" key={member.name}>
              <span>{member.role}</span><h2>{member.name}</h2><p>{member.birth}</p><strong>{member.age}</strong><p className="family-member__fate">{member.fate}</p>
            </div>
          ))}
        </section>
        <section className="family-story__text">
          {family.story.map((paragraph) => <p key={paragraph}>{paragraph}</p>)}
          {family.archivalNote ? <aside><strong>Précision des archives</strong>{family.archivalNote}</aside> : null}
          <p className="family-source">{family.imageCredit}. <a href={family.sourceUrl} target="_blank" rel="noreferrer">Consulter la source documentaire ↗</a></p>
        </section>
      </article>
    </main>
  );
}
