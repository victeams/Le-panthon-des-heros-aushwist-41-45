export type FamilyMember = {
  name: string;
  role: string;
  birth: string;
  age: string;
  fate: string;
};

export type Family = {
  slug: string;
  name: string;
  city: string;
  address: string;
  deportation: string;
  camp: string;
  imageUrl: string;
  imageAlt: string;
  imageCredit: string;
  sourceUrl: string;
  excerpt: string;
  members: FamilyMember[];
  story: string[];
  archivalNote?: string;
};

export const families: Family[] = [
  {
    slug: "famille-dreyfus",
    name: "Famille Dreyfus",
    city: "Saint-Étienne · rassemblée à Lyon",
    address: "21, rue du Treuil, Saint-Étienne",
    deportation: "Convoi 71, parti de Drancy le 13 avril 1944",
    camp: "Auschwitz-Birkenau",
    imageUrl:
      "https://images.squarespace-cdn.com/content/v1/5cadef7b51f4d4fb6d1b63fc/1569017812304-4QCJRO9G9OQXKR2V279E/Dreyfus%2BArlette.jpg",
    imageAlt: "Edmond et Jeanne Dreyfus photographiés avec leurs enfants Arlette et Roland",
    imageCredit: "Mémorial de la Shoah, photographie reproduite par le CDDEJ de Lyon",
    sourceUrl:
      "https://www.deportesdelyon.fr/les-archives-par-famille-a-m/enfants-dreyfus",
    excerpt:
      "Edmond et Jeanne Dreyfus posent avec leurs deux enfants, Arlette et Roland. Arrêtés ensemble parce qu’ils étaient juifs, aucun des quatre n’est revenu d’Auschwitz.",
    members: [
      { name: "Edmond Dreyfus", role: "Père", birth: "22 avril 1898, Vitry-le-François", age: "45 ans", fate: "Décédé à Auschwitz le 18 avril 1944" },
      { name: "Jeanne Dreyfus, née Gensburger", role: "Mère", birth: "26 mai 1902, Strasbourg", age: "41 ans", fate: "Décédée à Auschwitz le 18 avril 1944" },
      { name: "Roland Louis Dreyfus", role: "Fils", birth: "19 octobre 1929, Strasbourg", age: "14 ans", fate: "Décédé à Auschwitz le 19 avril 1944" },
      { name: "Arlette Adèle Dreyfus", role: "Fille", birth: "22 juillet 1935, Strasbourg", age: "8 ans", fate: "Décédée à Auschwitz le 19 avril 1944" },
    ],
    story: [
      "Réfugiée à Saint-Étienne, la famille Dreyfus vivait au 21, rue du Treuil. La photographie réunit tout le foyer : Edmond, Jeanne, leur fils Roland et leur fille Arlette.",
      "Le 3 avril 1944, les quatre membres de la famille furent arrêtés parce qu’ils étaient juifs. Après leur transfert à Drancy, ils furent déportés ensemble vers Auschwitz-Birkenau par le convoi 71 du 13 avril 1944.",
      "Les actes officiels fixent le décès d’Edmond et de Jeanne au 18 avril 1944, puis ceux de Roland et d’Arlette au 19 avril. Les archives consultées ne permettent pas d’établir le procédé exact de leur mise à mort ; elles établissent qu’aucun des quatre n’est revenu d’Auschwitz.",
    ],
    archivalNote: "Une phrase de la notice du CDDEJ attribue par erreur 19 ans à Arlette et 15 ans à Roland. Leurs dates de naissance établissent qu’ils avaient respectivement 8 et 14 ans lors de la déportation.",
  },
  {
    slug: "famille-wassermann",
    name: "Famille Wassermann",
    city: "Lyon",
    address: "41 bis, avenue Lacassagne, Lyon 3e",
    deportation: "Convoi 61, parti de Drancy le 28 octobre 1943",
    camp: "Auschwitz-Birkenau",
    imageUrl:
      "https://images.squarespace-cdn.com/content/v1/5cadef7b51f4d4fb6d1b63fc/1568024594504-81PKC0H8MP4M0HUVQLDZ/Wasser%2BHenry%2BJules%2Bet%2BAmalie%2BWasserman%2Bposant%2Bavec%2Bleur%2Bfils%2BHenri.%2BFrance%2C%2Bvers%2B1942.jpg",
    imageAlt: "Jules et Madeleine Amalie Wassermann photographiés avec leur fils Henri vers 1942",
    imageCredit: "Mémorial de la Shoah, photographie reproduite par le CDDEJ de Lyon",
    sourceUrl:
      "https://www.deportesdelyon.fr/les-archives-par-famille-n-z/henri-wassermann-wasser",
    excerpt:
      "À Lyon, Jules et Madeleine Amalie Wassermann posent avec leur fils unique Henri. Déportés ensemble par le convoi 61, tous trois sont morts à Auschwitz.",
    members: [
      { name: "Jules Wassermann", role: "Père", birth: "5 juillet 1891, Aufhausen", age: "52 ans", fate: "Décédé à Auschwitz le 2 novembre 1943" },
      { name: "Madeleine Amalie Wassermann, née Haas", role: "Mère", birth: "26 mars 1899, Kassel", age: "44 ans", fate: "Décédée à Auschwitz le 2 novembre 1943" },
      { name: "Henri Wassermann, dit Wasser", role: "Fils unique", birth: "15 juin 1925, Francfort-sur-le-Main", age: "18 ans", fate: "Décédé à Auschwitz le 2 novembre 1943" },
    ],
    story: [
      "Vers 1942, Jules et Madeleine Amalie Wassermann se firent photographier en France avec leur fils unique Henri. Leur dernière adresse connue était le 41 bis, avenue Lacassagne, dans le troisième arrondissement de Lyon.",
      "Jules, Madeleine Amalie et Henri furent rassemblés à Lyon, internés à Drancy, puis déportés ensemble vers Auschwitz-Birkenau par le convoi 61 du 28 octobre 1943. Mille personnes se trouvaient dans ce convoi.",
      "Les actes français portant la mention « Mort en déportation » fixent leur décès au 2 novembre 1943 à Auschwitz. Ils ne décrivent pas les circonstances individuelles de leur mort. Aucun membre de ce foyer n’est revenu.",
    ],
    archivalNote: "Les sources présentent plusieurs graphies du nom — Wassermann, Wasserman ou Wasser — et hésitent entre Kassel et Francfort-sur-le-Main pour le lieu de naissance d’Henri. La date et le lieu officiels du décès sont conservés sans extrapoler la méthode de mise à mort.",
  },
  {
    slug: "famille-pikovsky",
    name: "Famille Pikovsky",
    city: "Boulogne-Billancourt · photographiée à Joinville-le-Pont",
    address: "50, rue Georges-Sorel, Boulogne-Billancourt",
    deportation: "Convoi 67, parti de Drancy le 3 février 1944",
    camp: "Auschwitz-Birkenau",
    imageUrl:
      "https://webdoc.france24.com/si-je-reviens-un-jour-louise-pikovsky/chapitre-4/img/photos/dejeuner-2.jpg",
    imageAlt: "Abraham et Barbe Brunette Pikovsky avec leurs enfants Annette, Louise, Jean et Lucie en août 1943",
    imageCredit: "© Claude Counord, photographie familiale publiée par France 24",
    sourceUrl:
      "https://webdoc.france24.com/si-je-reviens-un-jour-louise-pikovsky/chapitre-4/index.html",
    excerpt:
      "En août 1943, Abraham et Barbe Brunette Pikovsky sont photographiés avec leurs quatre enfants, Annette, Louise, Jean et Lucie. Arrêtés ensemble à Boulogne-Billancourt, aucun des six n’est revenu d’Auschwitz.",
    members: [
      { name: "Abraham Pikovsky", role: "Père", birth: "17 décembre 1896, Nikolaïev", age: "47 ans", fate: "Déporté à Auschwitz ; non revenu" },
      { name: "Barbe Brunette Pikovsky, née Kohn", role: "Mère", birth: "Paris", age: "Âge non précisé par la source", fate: "Déportée à Auschwitz ; non revenue" },
      { name: "Annette Hélène Pikovsky", role: "Fille", birth: "3 février 1926, Paris 9e", age: "18 ans", fate: "Décédée officiellement à Auschwitz le 8 février 1944" },
      { name: "Louise Hélène Pikovsky", role: "Fille", birth: "7 décembre 1927, Paris 19e", age: "16 ans", fate: "Décédée officiellement à Auschwitz le 8 février 1944" },
      { name: "Jean Salomon Pikovsky", role: "Fils", birth: "10 septembre 1929, Paris 19e", age: "14 ans", fate: "Décédé officiellement à Auschwitz le 8 février 1944" },
      { name: "Lucie Suzanne Pikovsky", role: "Fille", birth: "16 mai 1932, Paris 19e", age: "11 ans", fate: "Décédée officiellement à Auschwitz le 8 février 1944" },
    ],
    story: [
      "La photographie a été prise en août 1943 à Joinville-le-Pont. Elle montre le foyer au complet : Barbe Brunette, Annette, Lucie, Louise, Abraham et Jean. La famille vivait au 50, rue Georges-Sorel, à Boulogne-Billancourt.",
      "Le 22 janvier 1944, les six membres de la famille furent arrêtés à leur domicile, puis internés à Drancy. Ils furent déportés ensemble vers Auschwitz-Birkenau par le convoi 67 du 3 février 1944.",
      "Aucune trace retrouvée dans les archives d’Auschwitz n’établit qu’un membre de la famille ait été sélectionné pour le travail. Les quatre enfants ont reçu après-guerre une date officielle de décès au 8 février 1944. Aucun membre du foyer n’est revenu ; les circonstances individuelles exactes de leur mise à mort ne sont pas documentées.",
    ],
    archivalNote: "La date du 8 février 1944 portée sur les actes des quatre enfants est une date administrative, établie après-guerre en ajoutant cinq jours à la date de départ du convoi ; elle ne constitue pas une preuve matérielle du jour exact de leur mort.",
  },
  {
    slug: "famille-adamsbaum",
    name: "Famille Adamsbaum",
    city: "Lens · réfugiée à Brezolles",
    address: "Rue de Verneuil, Brezolles (Eure-et-Loir)",
    deportation: "Convois 5 et 69, partis de France en 1942 et 1944",
    camp: "Auschwitz-Birkenau",
    imageUrl:
      "https://lestemoins.fr/sites/default/files/public/media/temoignage/01-adamsbaum.jpg",
    imageAlt: "Henoch et Lisa Adamsbaum avec leurs fils Albert et Jacki vers 1937",
    imageCredit: "Archives familiales, Cercil–Musée Mémorial des enfants du Vel d’Hiv",
    sourceUrl:
      "https://www.lestemoins.fr/content/henoch-adamsbaum-0",
    excerpt:
      "Henoch et Lisa Adamsbaum posent avec leurs deux fils, Albert et Jacki. Après Nîmes et Lens, la famille s’était réfugiée à Brezolles. Tous quatre furent déportés à Auschwitz et aucun ne revint.",
    members: [
      { name: "Henoch Adamsbaum", role: "Père", birth: "29 juin 1898, Varsovie", age: "44 ans", fate: "Assassiné à Auschwitz le 8 juillet 1942" },
      { name: "Lisa Adamsbaum, née Rubin", role: "Mère", birth: "1904, Łódź", age: "Environ 40 ans", fate: "Déportée à Auschwitz ; non revenue" },
      { name: "Aribert « Albert » Adamsbaum", role: "Fils", birth: "23 juillet 1929, Cologne", age: "14 ans", fate: "Déporté à Auschwitz ; non revenu" },
      { name: "Siegfried « Jacki » Adamsbaum", role: "Fils", birth: "29 octobre 1930, Cologne", age: "13 ans", fate: "Déporté à Auschwitz ; non revenu" },
    ],
    story: [
      "La famille Adamsbaum quitta l’Allemagne nazie pour la France en 1933. Après Nîmes, Henoch, Lisa et leurs fils Albert et Jacki vécurent à Lens, puis se réfugièrent à Brezolles, en Eure-et-Loir, où les garçons furent scolarisés.",
      "Henoch fut arrêté à son domicile le 25 juin 1942, interné à Beaune-la-Rolande, puis déporté à Auschwitz par le convoi 5 du 28 juin. Le Cercil établit qu’il y fut assassiné le 8 juillet 1942.",
      "Lisa et les deux garçons restèrent à Brezolles. Ils furent arrêtés ensemble le 23 février 1944 et déportés vers Auschwitz par le convoi 69 du 7 mars 1944. Aucun des trois ne revint. Les sources consultées ne documentent pas leurs circonstances individuelles de mort.",
    ],
    archivalNote: "La photographie familiale est datée avec prudence « 1937 ? » par le Cercil. La source donne l’année de naissance de Lisa, sans jour ni mois, et ne précise pas les dates de décès d’Albert, de Jacki et de leur mère.",
  },
];
