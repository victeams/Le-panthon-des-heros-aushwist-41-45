from __future__ import annotations

import base64
import json
import os
import tempfile
import threading
import webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

from portrait_core import PortraitData, create_portrait, ensure_clean, find_repository, publish

HTML = r'''<!doctype html><html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Mémoire des Déportés — Nouveau portrait</title><style>:root{--bg:#0d0f12;--panel:#181b20;--line:#494238;--gold:#d4ad62;--text:#f4f1e8;--muted:#b9bec6}*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--text);font:16px/1.5 Arial,sans-serif}main{width:min(920px,94vw);margin:30px auto 70px}h1{margin:0;font:clamp(2rem,5vw,3rem) Georgia,serif}.intro{color:var(--muted)}form{display:grid;grid-template-columns:240px 1fr;gap:13px 18px;margin-top:22px;padding:24px;border:1px solid var(--line);border-radius:16px;background:var(--panel)}label{font-weight:700;padding-top:11px}input,select,textarea{width:100%;padding:12px;border:1px solid #555d68;border-radius:9px;background:#0e1014;color:var(--text);font:inherit}textarea{min-height:260px;resize:vertical}.hint{grid-column:2;color:var(--muted);font-size:.85rem;margin-top:-7px}.actions{grid-column:1/-1;display:flex;gap:10px;flex-wrap:wrap;margin-top:8px}button{min-height:46px;padding:10px 17px;border:1px solid #76633f;border-radius:999px;background:#d4ad6216;color:var(--gold);font-weight:800;cursor:pointer}button.primary{background:var(--gold);color:#17120c}button:disabled{opacity:.5;cursor:wait}#status{grid-column:1/-1;margin:5px 0 0;color:var(--muted);white-space:pre-wrap}.success{color:#9ce3ae!important}.error{color:#ff9ca5!important}@media(max-width:700px){main{margin-top:18px}form{grid-template-columns:1fr;padding:18px}label{padding:5px 0 0}.hint{grid-column:1}.actions{grid-column:1}textarea{min-height:220px}}</style></head><body><main><h1>Créer un portrait</h1><p class="intro">Sans intelligence artificielle : le logiciel publie uniquement votre texte, votre photographie et votre source.</p><form id="form"><label for="repo">Dossier du site</label><input id="repo" required value="__REPO__"><label for="name">Prénom et NOM *</label><input id="name" required><label for="matricule">Matricule *</label><input id="matricule" required inputmode="numeric" maxlength="5" placeholder="31659, 45437…"><label for="birth">Nom de naissance</label><input id="birth"><label for="statusValue">Situation *</label><select id="statusValue"><option>Notice commémorative</option><option>Rescapé(e) de la déportation</option><option>Mort(e) en déportation</option></select><label for="biography">Biographie *</label><textarea id="biography" required placeholder="Collez ici le texte vérifié. Séparez les paragraphes par une ligne vide."></textarea><label for="sourceName">Nom de la source *</label><input id="sourceName" required value="Mémoire Vive"><label for="sourceUrl">URL complète de la source *</label><input id="sourceUrl" required type="url" placeholder="https://..."><label for="photo">Photographie</label><input id="photo" type="file" accept="image/jpeg,image/png,image/webp,image/gif"><p class="hint">Facultatif. Sans photo, le site affichera l’image « photographie non retrouvée ».</p><label for="credit">Crédit photographique</label><input id="credit" placeholder="Obligatoire si une photo est choisie"><label for="rights">Droits de la photo</label><input id="rights" value="Droits réservés"><div class="actions"><button id="publish" class="primary" type="submit">Créer et publier sur GitHub</button><button type="reset">Effacer le formulaire</button><button id="closeApp" type="button">Fermer le logiciel</button></div><p id="status">Prêt.</p></form></main><script>const form=document.querySelector('#form'),statusBox=document.querySelector('#status'),publish=document.querySelector('#publish');const fileData=file=>new Promise((resolve,reject)=>{if(!file)return resolve({photo_name:'',photo_data:''});const reader=new FileReader();reader.onload=()=>resolve({photo_name:file.name,photo_data:String(reader.result).split(',')[1]});reader.onerror=reject;reader.readAsDataURL(file)});document.querySelector('#closeApp').addEventListener('click',async()=>{await fetch('/shutdown',{method:'POST'});document.body.innerHTML='<main><h1>Logiciel fermé</h1><p class="intro">Vous pouvez fermer cet onglet.</p></main>'});form.addEventListener('submit',async event=>{event.preventDefault();const file=document.querySelector('#photo').files[0];if(file&&!document.querySelector('#credit').value.trim()){alert('Indiquez le crédit de la photographie.');return}const summary=`Personne : ${name.value}\nMatricule : ${matricule.value}\nSource : ${sourceName.value}\nPhoto : ${file?file.name:'aucune'}\n\nCréer cette fiche et la publier sur GitHub ?`;if(!confirm(summary))return;publish.disabled=true;statusBox.className='';statusBox.textContent='Création et publication en cours…';try{const photo=await fileData(file);const body={repo:repo.value,name:name.value,matricule:matricule.value,birth_name:birth.value,status:statusValue.value,biography:biography.value,source_name:sourceName.value,source_url:sourceUrl.value,photo_credit:credit.value,photo_rights:rights.value,...photo};const response=await fetch('/publish',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(body)});const result=await response.json();if(!response.ok)throw new Error(result.error||'Publication impossible');statusBox.className='success';statusBox.innerHTML=`Publié : <a style="color:#d4ad62" target="_blank" href="${result.url}">${result.filename}</a>\nGitHub reconstruit maintenant les catalogues.`;form.reset();repo.value=body.repo;sourceName.value='Mémoire Vive';rights.value='Droits réservés'}catch(error){statusBox.className='error';statusBox.textContent=error.message}finally{publish.disabled=false}});</script></body></html>'''

class Handler(BaseHTTPRequestHandler):
    server_version = "MemoirePortraits/1.0"
    def log_message(self, *_args): return
    def send_json(self, status: int, payload: dict) -> None:
        body=json.dumps(payload,ensure_ascii=False).encode("utf-8"); self.send_response(status); self.send_header("Content-Type","application/json; charset=utf-8"); self.send_header("Content-Length",str(len(body))); self.end_headers(); self.wfile.write(body)
    def do_GET(self):
        if urlparse(self.path).path != "/": self.send_error(404); return
        try: repo=find_repository()
        except Exception: repo=Path.cwd()
        body=HTML.replace("__REPO__",str(repo).replace("&","&amp;").replace('"',"&quot;")).encode("utf-8")
        self.send_response(200); self.send_header("Content-Type","text/html; charset=utf-8"); self.send_header("Content-Length",str(len(body))); self.send_header("Cache-Control","no-store"); self.end_headers(); self.wfile.write(body)
    def do_POST(self):
        route = urlparse(self.path).path
        if route == "/shutdown":
            self.send_json(200, {"closed": True})
            threading.Thread(target=self.server.shutdown, daemon=True).start()
            return
        if route != "/publish": self.send_error(404); return
        try:
            length=int(self.headers.get("Content-Length","0"))
            if length<=0 or length>30_000_000: raise ValueError("La demande est vide ou la photographie dépasse la taille autorisée.")
            payload=json.loads(self.rfile.read(length).decode("utf-8")); repo=Path(payload["repo"]).expanduser().resolve(); detected=find_repository(repo)
            if detected != repo: raise ValueError("Le dossier choisi n’est pas la racine du dépôt du mémorial.")
            ensure_clean(repo); temporary=None
            try:
                if payload.get("photo_data"):
                    suffix=Path(payload.get("photo_name","photo.jpg")).suffix.casefold() or ".jpg"; temporary=tempfile.NamedTemporaryFile(delete=False,suffix=suffix); temporary.write(base64.b64decode(payload["photo_data"],validate=True)); temporary.close()
                data=PortraitData(name=payload.get("name",""),matricule=payload.get("matricule",""),birth_name=payload.get("birth_name",""),status=payload.get("status",""),biography=payload.get("biography",""),source_url=payload.get("source_url",""),source_name=payload.get("source_name",""),photo_path=temporary.name if temporary else "",photo_credit=payload.get("photo_credit",""),photo_rights=payload.get("photo_rights",""))
                html_path,image_path=create_portrait(repo,data); publish(repo,html_path,image_path,data.name)
            finally:
                if temporary: Path(temporary.name).unlink(missing_ok=True)
            self.send_json(200,{"filename":html_path.name,"url":f"https://memoiredesdeportes.fr/{html_path.name}"})
        except Exception as error: self.send_json(400,{"error":str(error)})

def main() -> None:
    port=int(os.environ.get("MEMOIRE_PORTRAITS_PORT", "0")); server=ThreadingHTTPServer(("127.0.0.1",port),Handler); url=f"http://127.0.0.1:{server.server_port}/";
    if os.environ.get("MEMOIRE_PORTRAITS_NO_BROWSER") != "1": threading.Timer(.6,lambda:webbrowser.open(url)).start()
    server.serve_forever()
if __name__ == "__main__": main()
