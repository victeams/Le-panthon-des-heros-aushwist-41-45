import { mkdir, readFile, readdir, writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { portraits } from "../data/portraits.ts";
import { families } from "../data/families.ts";

const projectRoot = dirname(dirname(fileURLToPath(import.meta.url)));
const portraitsDirectory = join(projectRoot, "portraits");
const familiesDirectory = join(projectRoot, "familles");
const githubBase = "https://victeams.github.io/enfants-deportes-1939-1945";
const formerSiteBase = "https://enfants-deportes-1939-1945.fdhrddsveg.chatgpt.site";

const escapeHtml = (value = "") =>
  String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");

function portraitPage(portrait) {
  const canonical = `${githubBase}/portraits/${portrait.slug}.html`;
  const facts = [
    ["Naissance", `${portrait.birthDate}, ${portrait.birthPlace}`],
    ["Âge", portrait.ageLabel],
    ["Déportation", portrait.camp],
    ["Destin", portrait.outcome],
    portrait.deathDate
      ? ["Décès", `${portrait.deathDate}${portrait.deathPlace ? `, ${portrait.deathPlace}` : ""}`]
      : null,
  ].filter(Boolean);

  return `<!doctype html>
<html lang="fr">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>${escapeHtml(portrait.name)} · Enfants déportés 1939-1945</title>
    <meta name="description" content="${escapeHtml(portrait.excerpt)}" />
    <meta name="robots" content="index, follow, max-image-preview:large" />
    <link rel="canonical" href="${canonical}" />
    <meta property="og:title" content="${escapeHtml(portrait.name)}" />
    <meta property="og:description" content="${escapeHtml(portrait.excerpt)}" />
    <meta property="og:type" content="article" />
    <meta property="og:url" content="${canonical}" />
    <meta property="og:image" content="${escapeHtml(portrait.imageUrl)}" />
    <style>
      :root { color-scheme: dark; --paper:#11110f; --raised:#191815; --ink:#eeeae1; --muted:#b7b0a4; --line:#37332d; --gold:#d7bd8d; --wine:#5b2428; }
      * { box-sizing:border-box; }
      body { margin:0; background:var(--paper); color:var(--ink); font-family:Inter,system-ui,-apple-system,"Segoe UI",sans-serif; line-height:1.7; }
      a { color:inherit; }
      header, main, footer { width:min(980px,calc(100% - 1.4rem)); margin-inline:auto; }
      .site-header { display:flex; justify-content:space-between; align-items:center; min-height:64px; border-bottom:1px solid var(--line); }
      .brand, .back { color:var(--gold); text-decoration:none; }
      main { padding:clamp(2rem,7vw,5rem) 0; }
      article { overflow:hidden; border:1px solid var(--line); background:var(--raised); }
      .hero { display:grid; grid-template-columns:minmax(280px,.8fr) minmax(0,1.2fr); }
      figure { display:grid; place-items:center; margin:0; padding:1.2rem; background:#0d0d0b; }
      figure img { width:100%; max-height:620px; object-fit:contain; }
      .identity { padding:clamp(1.5rem,5vw,3.5rem); }
      .eyebrow { color:var(--gold); font-size:.72rem; font-weight:700; letter-spacing:.16em; text-transform:uppercase; }
      h1 { margin:.6rem 0 1rem; font-family:Georgia,serif; font-size:clamp(2.7rem,7vw,5.5rem); font-weight:400; line-height:1.05; }
      .lead { color:#d1cbc0; font-family:Georgia,serif; font-size:1.15rem; }
      dl { display:grid; gap:.7rem; margin:2rem 0 0; }
      dl div { display:grid; grid-template-columns:110px 1fr; gap:1rem; padding-top:.7rem; border-top:1px solid var(--line); }
      dt { color:var(--muted); font-size:.72rem; font-weight:700; letter-spacing:.08em; text-transform:uppercase; }
      dd { margin:0; }
      .story { padding:clamp(1.5rem,5vw,3.5rem); border-top:1px solid var(--line); }
      .story p { max-width:760px; margin:0 auto 1.15rem; font-family:Georgia,serif; font-size:clamp(1.05rem,2vw,1.2rem); }
      .source { max-width:760px; margin:2rem auto 0; padding-top:1rem; border-top:1px solid var(--line); color:var(--muted); font-size:.85rem; }
      .source a { color:var(--gold); }
      footer { padding:2rem 0; border-top:1px solid var(--line); color:var(--muted); font-size:.8rem; }
      @media (max-width:720px) { .hero { grid-template-columns:1fr; } dl div { grid-template-columns:1fr; gap:.2rem; } }
    </style>
  </head>
  <body>
    <header class="site-header">
      <a class="brand" href="../">✦ Enfants déportés</a>
      <a class="back" href="../#portraits">← Tous les portraits</a>
    </header>
    <main>
      <article>
        <section class="hero">
          <figure><img src="${escapeHtml(portrait.imageUrl)}" alt="${escapeHtml(portrait.imageAlt)}" /></figure>
          <div class="identity">
            <p class="eyebrow">Portrait documenté</p>
            <h1>${escapeHtml(portrait.name)}</h1>
            <p class="lead">${escapeHtml(portrait.excerpt)}</p>
            <dl>${facts.map(([label, value]) => `<div><dt>${escapeHtml(label)}</dt><dd>${escapeHtml(value)}</dd></div>`).join("")}</dl>
          </div>
        </section>
        <section class="story">
          ${portrait.biography.map((paragraph) => `<p>${escapeHtml(paragraph)}</p>`).join("\n          ")}
          <p class="source">${escapeHtml(portrait.imageCredit)}. <a href="${escapeHtml(portrait.sourceUrl)}" target="_blank" rel="noreferrer">Consulter la notice d’archive</a></p>
        </section>
      </article>
    </main>
    <footer>Enfants déportés 1939-1945 · Mémoire, documentation, transmission.</footer>
  </body>
</html>\n`;
}

const familyCss = `:root{color-scheme:dark;--paper:#11110f;--raised:#191815;--ink:#eeeae1;--muted:#b7b0a4;--line:#37332d;--gold:#d7bd8d}*{box-sizing:border-box}body{margin:0;background:var(--paper);color:var(--ink);font-family:Inter,system-ui,-apple-system,"Segoe UI",sans-serif;line-height:1.65}a{color:inherit}.site,main,footer{width:min(1120px,calc(100% - 1.4rem));margin-inline:auto}.site{display:flex;justify-content:space-between;align-items:center;min-height:64px;border-bottom:1px solid var(--line)}.site a,.back,.source a{color:var(--gold);text-decoration:none}.intro{display:grid;grid-template-columns:1fr .75fr;gap:clamp(2rem,8vw,8rem);align-items:end;padding:clamp(3rem,8vw,6rem) 0;border-bottom:1px solid var(--line)}.eyebrow,.member>span{color:var(--gold);font-size:.7rem;font-weight:700;letter-spacing:.14em;text-transform:uppercase}h1,h2,h3{font-family:Georgia,serif;font-weight:400;line-height:1.08}h1{margin:.6rem 0;font-size:clamp(3rem,8vw,6.5rem)}.intro p,.lead{color:#d1cbc0;font-family:Georgia,serif;font-size:1.08rem}.cards{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:2rem;margin:4rem 0}.card{overflow:hidden;border:1px solid var(--line);background:var(--raised)}.photo{position:relative;display:block;aspect-ratio:1.35;overflow:hidden;background:#0d0d0b}.photo img{width:100%;height:100%;object-fit:contain}.photo span{position:absolute;right:1rem;bottom:1rem;padding:.45rem .65rem;background:rgba(17,17,15,.88);color:var(--gold);font-size:.68rem;font-weight:700;text-transform:uppercase}.body{display:grid;min-height:320px;padding:2rem}.body h2{margin:.3rem 0 .9rem;font-size:clamp(2rem,4vw,3.2rem)}.body h2 a{text-decoration:none}.body>p:not(.eyebrow){color:#cbc5bb;font-family:Georgia,serif}.read{align-self:end;display:flex;justify-content:space-between;margin-top:1.5rem;padding-top:1rem;border-top:1px solid var(--line);color:var(--gold);font-size:.76rem;font-weight:700;text-decoration:none;text-transform:uppercase}.rights,footer{color:var(--muted);font-size:.75rem}.back{display:inline-block;margin:2.5rem 0}.hero{display:grid;grid-template-columns:.9fr 1.1fr;gap:clamp(2rem,7vw,7rem)}figure{margin:0}figure img{display:block;width:100%;max-height:680px;object-fit:contain;background:#1b1a17}figcaption{margin-top:.7rem;color:var(--muted);font-size:.75rem}.facts{display:grid;margin-top:2rem;border-top:1px solid var(--line)}.facts div{display:grid;grid-template-columns:110px 1fr;gap:1rem;padding:.8rem 0;border-bottom:1px solid var(--line)}dt{color:var(--muted);font-size:.7rem;text-transform:uppercase}dd{margin:0}.members{display:grid;grid-template-columns:repeat(4,1fr);gap:1px;margin:3rem 0;border:1px solid var(--line);background:var(--line)}.member{padding:1.2rem;background:var(--raised)}.member h2{margin:.5rem 0 1rem;font-size:1.3rem}.member p,.member strong{display:block;margin:.25rem 0;color:var(--muted);font-size:.8rem}.member strong{color:var(--ink)}.member .fate{margin-top:1rem;color:#d39b9f}.story{width:min(780px,100%);margin-inline:auto;color:#d6d0c5;font-family:Georgia,serif;font-size:1.12rem;line-height:1.85}.story aside{margin:2rem 0;padding:1rem 1.2rem;border-left:3px solid var(--gold);background:var(--raised);color:var(--muted);font-family:Inter,sans-serif;font-size:.8rem}.story aside strong{display:block;color:var(--gold)}.source{margin-top:2rem;padding-top:1rem;border-top:1px solid var(--line);color:var(--muted);font-family:Inter,sans-serif;font-size:.8rem}footer{margin-top:6rem;padding:2rem 0;border-top:1px solid var(--line)}@media(max-width:800px){.intro,.hero,.cards{grid-template-columns:1fr}.members{grid-template-columns:repeat(2,1fr)}}@media(max-width:560px){.members{grid-template-columns:1fr}.facts div{grid-template-columns:1fr;gap:.2rem}}`;

function familiesPage() {
  const cards = families.map((family) => `<article class="card"><a class="photo" href="${escapeHtml(family.slug)}.html"><img src="${escapeHtml(family.imageUrl)}" alt="${escapeHtml(family.imageAlt)}" loading="lazy" /><span>${family.members.length} membres · aucun retour</span></a><div class="body"><p class="eyebrow">${escapeHtml(family.city)}</p><h2><a href="${escapeHtml(family.slug)}.html">${escapeHtml(family.name)}</a></h2><p>${escapeHtml(family.excerpt)}</p><a class="read" href="${escapeHtml(family.slug)}.html">Lire leur histoire complète <span>→</span></a></div></article>`).join("");
  return `<!doctype html><html lang="fr"><head><meta charset="utf-8" /><meta name="viewport" content="width=device-width,initial-scale=1" /><title>Portraits de familles juives déportées</title><meta name="description" content="Photographies authentiques de familles ayant vécu en France et déportées à Auschwitz." /><link rel="canonical" href="${githubBase}/familles/" /><style>${familyCss}</style></head><body><header class="site"><a href="../">✦ Enfants déportés</a><a href="../#portraits">Portraits d’enfants</a></header><main><section class="intro"><div><p class="eyebrow">France · Photographies familiales authentiques</p><h1>Des familles réunies sur une même image</h1></div><p>Chaque carte montre le foyer photographié ensemble avant sa déportation. Ouvrez un portrait pour découvrir les noms, le convoi et ce que les archives établissent sur la mort de chacun.</p></section><section class="cards">${cards}</section><p class="rights">Les photographies sont présentées dans leur cadrage d’origine. Le crédit et la source documentaire sont indiqués sur chaque portrait.</p></main><footer>Enfants déportés 1939-1945 · Mémoire, documentation, transmission.</footer></body></html>\n`;
}

function familyPage(family) {
  const canonical = `${githubBase}/familles/${family.slug}.html`;
  return `<!doctype html><html lang="fr"><head><meta charset="utf-8" /><meta name="viewport" content="width=device-width,initial-scale=1" /><title>${escapeHtml(family.name)} · Enfants déportés</title><meta name="description" content="${escapeHtml(family.excerpt)}" /><link rel="canonical" href="${canonical}" /><meta property="og:image" content="${escapeHtml(family.imageUrl)}" /><style>${familyCss}</style></head><body><header class="site"><a href="../">✦ Enfants déportés</a><a href="./">Familles</a></header><main><a class="back" href="./">← Tous les portraits de familles</a><article><section class="hero"><figure><img src="${escapeHtml(family.imageUrl)}" alt="${escapeHtml(family.imageAlt)}" /><figcaption>${escapeHtml(family.imageCredit)}</figcaption></figure><div><p class="eyebrow">${escapeHtml(family.city)} · Famille photographiée au complet</p><h1>${escapeHtml(family.name)}</h1><p class="lead">${escapeHtml(family.excerpt)}</p><dl class="facts"><div><dt>Adresse</dt><dd>${escapeHtml(family.address)}</dd></div><div><dt>Déportation</dt><dd>${escapeHtml(family.deportation)}</dd></div><div><dt>Destination</dt><dd>${escapeHtml(family.camp)}</dd></div></dl></div></section><section class="members">${family.members.map((member) => `<div class="member"><span>${escapeHtml(member.role)}</span><h2>${escapeHtml(member.name)}</h2><p>${escapeHtml(member.birth)}</p><strong>${escapeHtml(member.age)}</strong><p class="fate">${escapeHtml(member.fate)}</p></div>`).join("")}</section><section class="story">${family.story.map((paragraph) => `<p>${escapeHtml(paragraph)}</p>`).join("")}${family.archivalNote ? `<aside><strong>Précision des archives</strong>${escapeHtml(family.archivalNote)}</aside>` : ""}<p class="source">${escapeHtml(family.imageCredit)}. <a href="${escapeHtml(family.sourceUrl)}" target="_blank" rel="noreferrer">Consulter la source documentaire ↗</a></p></section></article></main><footer>Enfants déportés 1939-1945 · Mémoire, documentation, transmission.</footer></body></html>\n`;
}

await mkdir(portraitsDirectory, { recursive: true });
await mkdir(familiesDirectory, { recursive: true });

for (const portrait of portraits) {
  await writeFile(
    join(portraitsDirectory, `${portrait.slug}.html`),
    portraitPage(portrait),
    "utf8",
  );
}

await writeFile(join(familiesDirectory, "index.html"), familiesPage(), "utf8");
for (const family of families) {
  await writeFile(join(familiesDirectory, `${family.slug}.html`), familyPage(family), "utf8");
}

const indexPath = join(projectRoot, "index.html");
let indexHtml = await readFile(indexPath, "utf8");
indexHtml = indexHtml
  .replaceAll(`${formerSiteBase}/social-card.jpg`, `${githubBase}/social-card.jpg`)
  .replaceAll(`${formerSiteBase}/galerie`, `${githubBase}/#portraits`)
  .replaceAll(`${formerSiteBase}/#hommages`, `${githubBase}/#memoire`)
  .replaceAll(`${formerSiteBase}/#soutenir`, `${githubBase}/#memoire`)
  .replace(
    new RegExp(`${formerSiteBase.replaceAll(".", "\\.")}/portraits/([a-z0-9-]+)`, "g"),
    `${githubBase}/portraits/$1.html`,
  )
  .replaceAll(formerSiteBase, `${githubBase}/`)
  .replace('<section class="memory">', '<section class="memory" id="memoire">');
await writeFile(indexPath, indexHtml, "utf8");

const portraitFiles = (await readdir(portraitsDirectory))
  .filter((name) => name.endsWith(".html"))
  .sort((a, b) => a.localeCompare(b, "fr"));
const urls = [
  `${githubBase}/`,
  `${githubBase}/familles/`,
  ...families.map((family) => `${githubBase}/familles/${family.slug}.html`),
  ...portraitFiles.map((name) => `${githubBase}/portraits/${name}`),
];

const sitemapXml = `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${urls
  .map((url) => `  <url><loc>${escapeHtml(url)}</loc></url>`)
  .join("\n")}\n</urlset>\n`;

await writeFile(join(projectRoot, "sitemap.xml"), sitemapXml, "utf8");
await writeFile(join(projectRoot, "sitemap-google.txt"), `${urls.join("\n")}\n`, "utf8");

console.log(`GitHub Pages prêt : ${portraits.length} portraits, ${families.length} familles, ${urls.length} URL dans les sitemaps.`);
