"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import type { Portrait } from "../../data/portraits";

type Props = {
  portraits: Portrait[];
};

const outcomes = ["Tous", "Victimes", "Survivants"] as const;

export function PortraitExplorer({ portraits }: Props) {
  const [query, setQuery] = useState("");
  const [country, setCountry] = useState("Tous les pays");
  const [outcome, setOutcome] = useState<(typeof outcomes)[number]>("Tous");

  const countries = useMemo(
    () => ["Tous les pays", ...Array.from(new Set(portraits.map((item) => item.country)))],
    [portraits],
  );

  const filtered = useMemo(() => {
    const normalized = query.trim().toLocaleLowerCase("fr");
    return portraits.filter((portrait) => {
      const matchesQuery =
        !normalized ||
        [portrait.name, portrait.birthPlace, portrait.camp]
          .join(" ")
          .toLocaleLowerCase("fr")
          .includes(normalized);
      const matchesCountry = country === "Tous les pays" || portrait.country === country;
      const matchesOutcome =
        outcome === "Tous" ||
        (outcome === "Survivants" && portrait.outcome.startsWith("Surviv")) ||
        (outcome === "Victimes" && !portrait.outcome.startsWith("Surviv"));
      return matchesQuery && matchesCountry && matchesOutcome;
    });
  }, [country, outcome, portraits, query]);

  return (
    <section className="explorer" id="portraits" aria-labelledby="portraits-title">
      <div className="explorer__heading">
        <div>
          <p className="eyebrow">Archives nominatives</p>
          <h2 id="portraits-title">Retrouver un visage, lire une histoire</h2>
        </div>
        <p className="result-count" aria-live="polite">
          {filtered.length} {filtered.length > 1 ? "portraits" : "portrait"}
        </p>
      </div>

      <div className="filters" aria-label="Filtres des portraits">
        <label className="search-field">
          <span>Rechercher</span>
          <input
            type="search"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="Nom, ville ou camp"
          />
        </label>
        <label>
          <span>Pays</span>
          <select value={country} onChange={(event) => setCountry(event.target.value)}>
            {countries.map((item) => (
              <option key={item}>{item}</option>
            ))}
          </select>
        </label>
        <fieldset>
          <legend>Destin</legend>
          <div className="segmented">
            {outcomes.map((item) => (
              <button
                key={item}
                type="button"
                className={outcome === item ? "is-active" : ""}
                onClick={() => setOutcome(item)}
                aria-pressed={outcome === item}
              >
                {item}
              </button>
            ))}
          </div>
        </fieldset>
      </div>

      {filtered.length ? (
        <div className="portrait-grid">
          {filtered.map((portrait) => (
            <article className="portrait-card" key={portrait.slug}>
              <Link href={"/portraits/" + portrait.slug} className="portrait-card__image">
                {/* Archives are displayed in full, without cropping or alteration. */}
                {!portrait.outcome.startsWith("Surviv") ? (
                  <span className="portrait-card__status">{portrait.outcome}</span>
                ) : null}
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img src={portrait.imageUrl} alt={portrait.imageAlt} loading="lazy" />
              </Link>
              <div className="portrait-card__body">
                <div className="portrait-card__meta">
                  <span>{portrait.ageLabel}</span>
                  <span className={portrait.outcome.startsWith("Surviv") ? "status status--survived" : "status"}>
                    {portrait.outcome}
                  </span>
                </div>
                <h3>
                  <Link href={"/portraits/" + portrait.slug}>{portrait.name}</Link>
                </h3>
                <p>{portrait.excerpt}</p>
                <Link className="text-link" href={"/portraits/" + portrait.slug}>
                  Lire son histoire <span aria-hidden="true">→</span>
                </Link>
              </div>
            </article>
          ))}
        </div>
      ) : (
        <div className="empty-state">
          <p>Aucun portrait ne correspond à ces critères.</p>
          <button
            type="button"
            className="text-link"
            onClick={() => {
              setQuery("");
              setCountry("Tous les pays");
              setOutcome("Tous");
            }}
          >
            Effacer les filtres
          </button>
        </div>
      )}
    </section>
  );
}
