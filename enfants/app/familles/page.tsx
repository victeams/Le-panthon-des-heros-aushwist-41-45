import type { Metadata } from "next";
import Link from "next/link";
import { families } from "../../data/families";

export const metadata: Metadata = {
  title: "Portraits de familles juives déportées",
  description: "Photographies authentiques et histoires documentées de familles juives ayant vécu en France et déportées à Auschwitz-Birkenau.",
  alternates: { canonical: "/familles" },
};

export default function FamiliesPage() {
  return (
    <main className="families-page">
      <header className="families-hero">
        <div><p className="eyebrow">France · Photographies familiales authentiques</p><h1>Des familles réunies sur une même image</h1></div>
        <div className="families-hero__copy">
          <p>Chaque carte montre le foyer photographié ensemble avant sa déportation. Ouvrez un portrait pour découvrir les noms, l’adresse, le convoi et ce que les archives permettent d’établir sur la mort de chacun.</p>
          <p className="families-hero__warning">Aucune image de substitution : les photographies montrant seulement les enfants ou un document d’archive ont été retirées.</p>
        </div>
      </header>

      <section className="family-portrait-grid" aria-label="Portraits de familles">
        {families.map((family) => (
          <article className="family-portrait-card" key={family.slug}>
            <Link className="family-portrait-card__image" href={`/familles/${family.slug}`} aria-label={`Découvrir l’histoire de la ${family.name}`}>
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={family.imageUrl} alt={family.imageAlt} loading="lazy" />
              <span>{family.members.length} membres · aucun retour</span>
            </Link>
            <div className="family-portrait-card__body">
              <p className="eyebrow">{family.city}</p>
              <h2><Link href={`/familles/${family.slug}`}>{family.name}</Link></h2>
              <p>{family.excerpt}</p>
              <Link className="family-portrait-card__link" href={`/familles/${family.slug}`}>Lire leur histoire complète <span aria-hidden="true">→</span></Link>
            </div>
          </article>
        ))}
      </section>

      <p className="families-rights">Les photographies sont présentées dans leur cadrage d’origine. Le crédit et la source documentaire sont indiqués sur chaque portrait.</p>
      <div className="families-back"><Link className="button button--outline" href="/#portraits">Revenir aux portraits d’enfants</Link></div>
    </main>
  );
}
