const input=document.getElementById('global-search');
  const groupFilter=document.getElementById('group-filter');
  const statusFilter=document.getElementById('status-filter');
  const resetButton=document.getElementById('reset-search');
  const result=document.getElementById('global-result');
  const grid=document.getElementById('global-grid');
  const dailyGrid=document.getElementById('daily-grid');
  const normalize=value=>String(value??'').normalize('NFD').replace(/[̀-ͯ]/g,'').toLowerCase();
  let people=[];
  const personCard=person=>{
    const article=document.createElement('article');article.className='card';
    const visual=document.createElement('a');visual.className='portrait-link';visual.href=person.file;
    if(person.portrait||person.group==='femmes'){
      const image=document.createElement('img');image.className='portrait';
      image.src=person.portrait||'images/photo-non-trouvee-femmes.jpg';
      image.alt=person.portrait_alt||`Photographie non retrouvée pour ${person.name}`;
      image.loading='lazy';visual.append(image);
    }else{
      const missing=document.createElement('span');missing.className='portrait-missing';
      missing.textContent='Portrait non disponible';visual.append(missing);
    }
    const top=document.createElement('div');const badge=document.createElement('span');
    badge.className=`badge ${person.status_class}`;badge.textContent=person.status;top.append(badge);
    const title=document.createElement('h2');title.textContent=person.name;
    const subtitle=document.createElement('p');subtitle.textContent=person.subtitle;
    const link=document.createElement('a');link.href=person.file;link.textContent='Découvrir son histoire →';
    article.append(visual,top,title,subtitle,link);return article;
  };
  const renderSearch=()=>{
    const query=normalize(input.value.trim());const group=groupFilter.value;const status=statusFilter.value;
    grid.replaceChildren();
    if(query.length<2&&!group&&!status){
      result.textContent=`Recherchez parmi ${people.length.toLocaleString('fr-FR')} biographies par nom, prénom ou matricule.`;return;
    }
    const allMatches=people.filter(person=>(!query||normalize(person.search).includes(query))&&(!group||person.group===group)&&(!status||person.status_class===status));
    allMatches.slice(0,60).forEach(person=>grid.append(personCard(person)));
    result.textContent=allMatches.length?`${allMatches.length.toLocaleString('fr-FR')} résultat${allMatches.length>1?'s':''}${allMatches.length>60?' — 60 premiers affichés':''}`:'Aucun portrait ne correspond à cette recherche.';
  };
  fetch('site-data.json').then(response=>response.json()).then(data=>{
    people=data;
    const withPortrait=people.filter(person=>person.portrait);
    const pool=withPortrait.length?withPortrait:people;
    if(pool.length){
      const today=new Date();const seed=Number(`${today.getUTCFullYear()}${today.getUTCMonth()+1}${today.getUTCDate()}`);
      dailyGrid.append(personCard(pool[seed%pool.length]));
    }
    renderSearch();
  }).catch(()=>{result.textContent='La recherche est momentanément indisponible.';});
  input.addEventListener('input',renderSearch);
  groupFilter.addEventListener('change',renderSearch);
  statusFilter.addEventListener('change',renderSearch);
  resetButton.addEventListener('click',()=>{input.value='';groupFilter.value='';statusFilter.value='';renderSearch();input.focus();});