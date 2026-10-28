#!/usr/bin/env python3
"""Repère les biographies à enrichir et prépare des pistes de recherche web.
Lecture seule : aucune biographie publiée n'est modifiée.
"""
from __future__ import annotations
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import quote_plus, urlparse, parse_qs
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError
import csv, html, re, sys, time

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "rapports"
PROFILE_DIRS = ("hommes", "femmes")
NON_PROFILE = {"index.html","femmes.html","hommes.html","base-documentaire.html","photos.html","tiktok.html","a-propos.html","mairies-partenaires.html","contact.html","convoi-des-31000.html","convoi-des-45000.html","carte-camps.html","carte-parcours.html","sitemap.html"}
MATRICULE_RE = re.compile(r"(?<!\d)(?:31|45|46)\d{3}(?!\d)")
MAX_LIVE_SEARCHES = 20  # Rotation quotidienne pour couvrir progressivement les fiches
SOURCE_SEARCHES = [
    ("Convoi 77", "site:convoi77.org"),
    ("Mémoire Vive", "site:memoire-vive.org"),
    ("Yad Vashem", "site:yadvashem.org"),
    ("Arolsen Archives", "site:arolsen-archives.org"),
    ("USHMM", "site:ushmm.org"),
    ("FranceArchives", "site:francearchives.gouv.fr"),
    ("Mémorial de la Shoah", "site:memorialdelashoah.org"),
    ("Déportés politiques à Auschwitz", "site:deportes-politiques-auschwitz.fr"),
    ("Archives nationales", "site:archives-nationales.culture.gouv.fr"),
]
class ProfileParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.title_depth=self.h1_depth=self.skip_depth=0
        self.title_parts=[]; self.h1_parts=[]; self.text_parts=[]; self.links=[]; self.images=[]; self.meta={}
    def handle_starttag(self, tag, attrs):
        attrs=dict(attrs)
        if tag=="title": self.title_depth+=1
        if tag=="h1": self.h1_depth+=1
        if tag in ("script","style","noscript"): self.skip_depth+=1
        if tag=="a": self.links.append(attrs.get("href",""))
        if tag=="img": self.images.append((attrs.get("src",""),attrs.get("alt","")))
        if tag=="meta":
            name=(attrs.get("name") or "").lower()
            if name: self.meta[name]=attrs.get("content","")
    def handle_endtag(self, tag):
        if tag=="title" and self.title_depth: self.title_depth-=1
        if tag=="h1" and self.h1_depth: self.h1_depth-=1
        if tag in ("script","style","noscript") and self.skip_depth: self.skip_depth-=1
    def handle_data(self,data):
        if self.skip_depth:return
        value=data.strip()
        if not value:return
        self.text_parts.append(value)
        if self.title_depth:self.title_parts.append(value)
        if self.h1_depth:self.h1_parts.append(value)
class SearchParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True); self.links=[]; self.active=None
    def handle_starttag(self,tag,attrs):
        if tag!="a":return
        attrs=dict(attrs); href=attrs.get("href","")
        if "result__a" in attrs.get("class","") and href:
            self.active={"href":href,"text":""}; self.links.append(self.active)
    def handle_data(self,data):
        if self.active:self.active["text"]+=data
    def handle_endtag(self,tag):
        if tag=="a":self.active=None
def clean(parts): return re.sub(r"\s+"," ",html.unescape(" ".join(parts))).strip()
def page_files():
    files={p for p in ROOT.glob("*.html") if p.name not in NON_PROFILE}
    for name in PROFILE_DIRS:
        folder=ROOT/name
        if folder.is_dir():files.update(folder.glob("*.html"))
    return sorted(p for p in files if p.is_file())
def parse(path):
    parser=ProfileParser()
    try:parser.feed(path.read_text(encoding="utf-8",errors="replace"))
    except OSError:return None
    title=clean(parser.h1_parts) or clean(parser.title_parts) or path.stem
    text=clean(parser.text_parts)
    match=MATRICULE_RE.search(f"{path.stem} {text} {parser.meta.get('convoi','')}")
    if not parser.h1_parts or not (match or parser.meta.get("convoi")):return None
    signals=[]
    if len(text)<700:signals.append(f"texte court ({len(text)} caractères visibles)")
    source_words=re.search(r"\b(source|sources|bibliographie|archives|référence|références|source photo|crédit photographique)\b",text,re.I)
    external_links=[u for u in parser.links if urlparse(u).scheme in ("http","https") and urlparse(u).netloc and "memoiredesdeportes.fr" not in urlparse(u).netloc]
    if not source_words and not external_links:signals.append("aucune source externe repérée automatiquement")
    if not re.search(r"\b(naissance|né[e]? le|né[e]? à|naît|né[e]? en)\b",text,re.I):signals.append("naissance/date ou lieu de naissance non repéré")
    if not re.search(r"\b(décédé[e]?|mort[e]?|tué[e]?|survivant[e]?|survécu|libéré[e]?|disparu[e]?|rentré[e]?)\b",text,re.I):signals.append("issue du parcours non repérée")
    if not re.search(r"\b(arrêté[e]?|arrestation|rafle|incarcéré[e]?|emprisonné[e]?)\b",text,re.I):signals.append("arrestation ou détention non repérée")
    if not re.search(r"\b(convoi|parti[e]? de|départ de|transport[e]? le)\b",text,re.I):signals.append("convoi ou départ non repéré")
    if not re.search(r"\b(camp|Auschwitz|Buchenwald|Ravensbrück|Dachau|Mauthausen|Neuengamme|Sachsenhausen|Bergen-Belsen|Flossenbürg)\b",text,re.I):signals.append("camp ou lieu de détention non repéré")
    if not re.search(r"\b(profession|ouvrier|ouvrière|employé[e]?|instituteur|institutrice|étudiant[e]?|métier)\b",text,re.I):signals.append("profession ou activité non repérée")
    if not parser.images:signals.append("aucune image intégrée")
    elif all(not alt.strip() for _,alt in parser.images):signals.append("images sans texte alternatif")
    return title,text,signals,external_links,match.group(0) if match else ""
def search_web(query):
    url="https://html.duckduckgo.com/html/?q="+quote_plus(query)
    req=Request(url,headers={"User-Agent":"Mozilla/5.0 (compatible; MemorialResearch/1.0)","Accept-Language":"fr-FR,fr;q=0.9,en;q=0.7"})
    try:
        with urlopen(req,timeout=12) as response: page=response.read(1500000).decode("utf-8","replace")
        parser=SearchParser();parser.feed(page);found=[]
        for item in parser.links:
            href=html.unescape(item["href"]).strip(); title=re.sub(r"\s+"," ",html.unescape(item["text"])).strip()
            if "uddg=" in href:href=parse_qs(urlparse(href).query).get("uddg",[href])[0]
            parsed=urlparse(href)
            if parsed.scheme not in ("http","https") or not parsed.netloc:continue
            if any(x in parsed.netloc.lower() for x in ("duckduckgo.com","google.com","bing.com")):continue
            if title and href not in [x["url"] for x in found]:found.append({"title":title[:180],"url":href})
            if len(found)>=5:break
        return found,""
    except (HTTPError,URLError,TimeoutError,OSError) as exc:return [],type(exc).__name__
def main():
    OUT.mkdir(parents=True,exist_ok=True);candidates=[];seen=set();analysed=0
    for path in page_files():
        parsed=parse(path)
        if not parsed:continue
        title,text,signals,external_links,matricule=parsed;analysed+=1
        identity=matricule or path.stem.lower()
        if identity in seen:continue
        seen.add(identity)
        if signals:candidates.append({"priority":len(signals),"sort":title.casefold(),"path":path.relative_to(ROOT).as_posix(),"title":title,"signals":signals,"external_links":external_links,"text_len":len(text),"matricule":matricule})
    candidates.sort(key=lambda x:(-x["priority"],x["sort"],x["path"]))
    from datetime import date
    live_errors=0
    if candidates:
        start = (date.today().toordinal() * MAX_LIVE_SEARCHES) % len(candidates)
        ordered = candidates[start:] + candidates[:start]
        selected_paths = {item['path'] for item in ordered[:min(len(candidates), MAX_LIVE_SEARCHES)]}
    else:
        selected_paths = set()
    for item in candidates:
        if item['path'] not in selected_paths:
            continue
        query='"'+item["title"].replace('"'," ")+'"'
        if item["matricule"]:query+=" "+item["matricule"]
        results,error=search_web(query+" déportation Auschwitz")
        item["web_results"]=results;item["search_error"]=error
        if error:live_errors+=1
        time.sleep(0.8)
    for item in candidates:
        if item["path"] not in selected_paths:
            item["web_results"]=[];item["search_error"]="Fiche programmée dans une prochaine rotation quotidienne de recherche web"
    md=["# Biographies à enrichir — recherches web quotidiennes","",
        "> Rapport indicatif en lecture seule. Les signaux automatiques ne prouvent pas qu'une information manque. Les résultats web sont des pistes à vérifier, pas des faits validés.","",
        f"- Biographies analysées : **{analysed}**",f"- Fiches avec au moins un point à examiner : **{len(candidates)}**",
        f"- Fiches recherchées sur le web aujourd'hui : **{len(selected_paths)}**",f"- Recherches web sans réponse exploitable : **{live_errors}**","","## Fiches à examiner",""]
    rows=[]
    for item in candidates:
        query=item["title"]+(" "+item["matricule"] if item["matricule"] else "")+" déportation Auschwitz"
        google="https://www.google.com/search?q="+quote_plus(query)
        md += [f"### {item['title']}","",f"- Fichier : {item['path']}",f"- Matricule repéré : {item['matricule'] or 'non repéré'}",
               f"- Texte visible : {item['text_len']} caractères ; liens externes déjà présents : {len(item['external_links'])}",
               "- Points à examiner : "+"; ".join(item["signals"]),f"- [Recherche web générale sur cette personne]({google})"]
        for label,domain_query in SOURCE_SEARCHES:
            url="https://www.google.com/search?q="+quote_plus(domain_query+" "+query)
            md.append(f"- [Rechercher dans {label}]({url})")
        if item["external_links"]:
            md.append("- Liens externes déjà présents : "+", ".join(f"[{urlparse(u).netloc}]({u})" for u in item["external_links"][:5]))
        if item["web_results"]:
            md.append("- Résultats web repérés automatiquement (à vérifier) :")
            for result in item["web_results"]:md.append(f"  - [{result['title'] or result['url']}]({result['url']})")
        elif item["search_error"]:md.append(f"- Recherche web directe : aucun résultat récupéré ({item['search_error']}). Les liens de recherche ci-dessus restent disponibles.")
        md.append("")
        rows.append({"biographie":item["title"],"fichier":item["path"],"matricule":item["matricule"],"longueur_texte":item["text_len"],"points_a_examiner":" | ".join(item["signals"]),"liens_externes_existants":" | ".join(item["external_links"]),"recherche_web":google,"resultats_web":" | ".join(r["url"] for r in item["web_results"]),"statut":"À vérifier manuellement"})
    md += ["## Sources à consulter","",
           "Privilégier les archives et organismes mémoriels reconnus : Convoi 77, Mémoire Vive, Yad Vashem, Arolsen Archives, United States Holocaust Memorial Museum, FranceArchives et les Archives nationales. Recouper les faits avec une source fiable avant tout enrichissement.","",
           "## Protection du mémorial","",
           "Ce rapport et le CSV ne modifient aucune biographie, photo, page publiée ni sitemap. Aucune donnée issue d'une recherche web n'est injectée automatiquement dans le site."]
    (OUT/"biographies-a-enrichir.md").write_text("\n".join(md)+"\n",encoding="utf-8")
    with (OUT/"biographies-a-enrichir.csv").open("w",newline="",encoding="utf-8-sig") as f:
        writer=csv.DictWriter(f,fieldnames=["biographie","fichier","matricule","longueur_texte","points_a_examiner","liens_externes_existants","recherche_web","resultats_web","statut"])
        writer.writeheader();writer.writerows(rows)
    print("\n".join(md));print(f"\nCSV créé : rapports/biographies-a-enrichir.csv")
    return 0
if __name__=="__main__":sys.exit(main())
