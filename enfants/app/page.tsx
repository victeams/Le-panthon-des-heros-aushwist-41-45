import { PortraitExplorer } from "./components/portrait-explorer";
import { TributeSection } from "./components/tribute-section";
import { portraits } from "../data/portraits";
import Link from "next/link";

export default function Home() {
  return (
    <main>
      <section className="intro" aria-labelledby="main-title">
        <div className="intro__copy">
          <p className="eyebrow">Mémorial numérique · 1939–1945</p>
          <h1 id="main-title">Enfants déportés</h1>
          <p className="intro__lead">
            Derrière chaque date se trouvait une enfance, une famille et un
            avenir. Ce mémorial rassemble leurs visages et leurs histoires pour
            que leurs noms ne disparaissent jamais.
          </p>
        </div>
        <aside className="intro__notice" aria-label="Avertissement">
          <span aria-hidden="true">✦</span>
          <p>
            Photographies d’archives documentées. Certains récits peuvent être
            bouleversants. Accompagnez les plus jeunes pendant la consultation.
          </p>
        </aside>
      </section>

      <section className="site-bridge" aria-labelledby="bridge-title">
        <div>
          <p className="eyebrow">Deux sites, une même transmission</p>
          <h2 id="bridge-title">Découvrir le Panthéon des héros</h2>
          <p>
            Poursuivez le travail de mémoire avec les portraits documentés de
            femmes et d’hommes résistants et déportés pendant la Seconde Guerre
            mondiale.
          </p>
        </div>
        <a
          className="button button--outline"
          href="https://victeams.github.io/Le-panthon-des-heros-aushwist-41-45/"
          target="_blank"
          rel="noreferrer"
        >
          Ouvrir le Panthéon des héros <span aria-hidden="true">↗</span>
        </a>
      </section>

      <section className="family-callout" aria-labelledby="family-callout-title">
        <div>
          <p className="eyebrow">Nouvelle rubrique · Lyon et sa région</p>
          <h2 id="family-callout-title">Une famille n’est pas une liste de noms</h2>
          <p>Découvrez les parents et les enfants qui partageaient une maison, une école et des projets avant d’être déportés ensemble vers Auschwitz-Birkenau.</p>
        </div>
        <Link className="button" href="/familles">Découvrir les familles</Link>
      </section>

      <PortraitExplorer portraits={portraits} />

      <section className="mission" id="comprendre" aria-labelledby="mission-title">
        <div>
          <p className="eyebrow">Comprendre et transmettre</p>
          <h2 id="mission-title">Une vie ne tient pas dans une statistique</h2>
        </div>
        <div className="mission__text">
          <p>
            Les enfants présentés ici venaient de pays, de familles et de
            milieux différents. Certains furent assassinés dès leur arrivée.
            D’autres survécurent grâce à une succession de gestes courageux et
            de circonstances exceptionnelles.
          </p>
          <p>
            Chaque fiche distingue les faits établis du récit mémoriel, indique
            l’origine des photographies et renvoie vers les institutions qui
            conservent les documents.
          </p>
        </div>
      </section>

      <TributeSection />

      <section className="support" id="soutenir" aria-labelledby="support-title">
        <div>
          <p className="eyebrow">Un site sans publicité</p>
          <h2 id="support-title">Soutenir le travail de mémoire</h2>
          <p>
            La consultation reste gratuite. Les dons servent à documenter de
            nouveaux portraits, préserver les archives et maintenir le site.
          </p>
        </div>
        <div className="support__action">
          <p>Dans PayPal, utilisez l’adresse :</p>
          <strong>tardy42350@gmail.com</strong>
          <a
            className="button button--light"
            href="https://www.paypal.com/fr/home"
            target="_blank"
            rel="noreferrer"
          >
            Ouvrir PayPal
          </a>
        </div>
      </section>
    </main>
  );
}
