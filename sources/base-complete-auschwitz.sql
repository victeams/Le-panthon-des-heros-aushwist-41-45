BEGIN TRANSACTION;
CREATE TABLE "camps" ("camp_id" TEXT PRIMARY KEY, "name" TEXT, "other_names" TEXT, "location_historic" TEXT, "location_current" TEXT, "start" TEXT, "end" TEXT, "primary_functions" TEXT, "key_places" TEXT, "notes" TEXT, "source_id" TEXT, "confidence" TEXT);
INSERT INTO "camps" VALUES('C01','Auschwitz I','Stammlager, camp principal','Oświęcim annexée au Reich allemand','Oświęcim, Pologne','1940-05','1945-01-27','Camp de concentration, administration du complexe, détention, travail forcé, exécutions','Porte Arbeit macht frei, Blocks 10 et 11, mur des exécutions, crématoire I','Installé dans d''anciennes casernes polonaises. Les premiers 728 prisonniers politiques polonais arrivent le 14 juin 1940.','S01','Établi');
INSERT INTO "camps" VALUES('C02','Auschwitz II-Birkenau','Birkenau','Brzezinka expulsée et germanisée','Brzezinka, Pologne','1941-10','1945-01-27','Camp de concentration, centre de mise à mort, sélection, travail forcé','Rampe intérieure, secteurs BI et BII, crématoires II à V, bunkers I et II, Canada','Plus vaste composante du complexe et principal lieu du meurtre de masse des Juifs déportés à Auschwitz.','S05','Établi');
INSERT INTO "camps" VALUES('C03','Auschwitz III-Monowitz','Monowitz, Buna','Monowice près d''Oświęcim','Monowice, Pologne','1942-10','1945-01','Camp de travail forcé au service du complexe industriel IG Farben','Usine Buna-Werke, baraquements de Monowitz','Devient Auschwitz III lors de la réorganisation de novembre 1943. Plus de 10 000 prisonniers y sont dénombrés le 17 janvier 1945.','S02','Établi');
CREATE TABLE "daily_life" ("topic_id" TEXT PRIMARY KEY, "theme" TEXT, "summary" TEXT, "human_impact" TEXT, "source_id" TEXT, "confidence" TEXT);
INSERT INTO "daily_life" VALUES('Q01','Réveil','Le travail journalier commençait vers 4 h 30 en été et 5 h 30 en hiver. Les prisonniers devaient ranger leur couchage, tenter de se laver et se rendre à l''appel.','Épuisement dès l''aube, manque de sommeil et absence d''intimité.','S07','Établi');
INSERT INTO "daily_life" VALUES('Q02','Appels','Les prisonniers étaient comptés en rangs. Toute différence prolongeait l''appel, parfois pendant des heures et par tous les temps.','Froid, chaleur, immobilité, coups et décès pendant les appels punitifs.','S07','Établi');
INSERT INTO "daily_life" VALUES('Q03','Travail forcé','À partir de mars 1942, la journée minimale de travail atteignait environ onze heures, davantage en été, dans l''industrie, les mines, les chantiers ou l''agriculture.','Accidents, violences, épuisement et sélection lorsque le corps ne pouvait plus travailler.','S07','Établi');
INSERT INTO "daily_life" VALUES('Q04','Faim','Trois distributions quotidiennes très insuffisantes: boisson chaude sans valeur nutritive, soupe pauvre, pain noir et petite garniture.','Amaigrissement extrême, maladie de la faim et vulnérabilité aux sélections.','S08','Établi');
INSERT INTO "daily_life" VALUES('Q05','Logement','Surpeuplement, couchettes partagées, baraques froides ou humides et infestations rendaient le repos presque impossible.','Propagation des maladies et dégradation rapide de la santé.','S07','Établi');
INSERT INTO "daily_life" VALUES('Q06','Hygiène','L''accès à l''eau, aux latrines et au linge propre était gravement insuffisant, particulièrement à Birkenau.','Humiliation, infections et épidémies.','S07','Établi');
INSERT INTO "daily_life" VALUES('Q07','Vêtements et marquage','Les détenus recevaient des vêtements de camp ou des effets civils marqués, un triangle de catégorie et, pour les enregistrés à Auschwitz, souvent un numéro tatoué.','Dépouillement de l''identité et exposition au froid.','S15','Établi');
INSERT INTO "daily_life" VALUES('Q08','Hôpitaux de camp','Les infirmeries disposaient de moyens dérisoires et servaient aussi de lieux de sélection et d''assassinat.','La maladie pouvait conduire à la mort faute de soins ou par sélection.','S07','Établi');
INSERT INTO "daily_life" VALUES('Q09','Punitions','Cellules, privation de nourriture, station debout, pendaisons, coups et travail dans des commandos pénaux faisaient partie du système de terreur.','Souffrance physique, peur permanente et mort.','S07','Établi');
INSERT INTO "daily_life" VALUES('Q10','Courrier et colis','Des lettres très contrôlées et, pour certaines catégories à partir de 1942, des colis étaient parfois autorisés. Les Juifs et prisonniers de guerre soviétiques étaient notamment exclus de certains privilèges.','Lien fragile avec les familles et inégalités organisées entre catégories.','S08','Établi');
INSERT INTO "daily_life" VALUES('Q11','Solidarité et résistance','Des prisonniers partageaient nourriture, informations et médicaments, organisaient des réseaux clandestins, transmettaient des preuves et préparaient des évasions.','Gestes vitaux de dignité et de survie malgré un risque extrême.','S09','Établi');
INSERT INTO "daily_life" VALUES('Q12','Mort et disparition des traces','Les décès résultaient de meurtres directs, de la faim, des maladies, du travail forcé, des mauvais traitements et des conditions de détention. De nombreux documents furent détruits.','Des familles entières furent anéanties et l''identité de nombreuses victimes reste à reconstituer.','S04','Établi');
CREATE TABLE "facilities" ("facility_id" TEXT PRIMARY KEY, "name" TEXT, "camp_id" TEXT, "type" TEXT, "period" TEXT, "function" TEXT, "fate" TEXT, "source_id" TEXT, "confidence" TEXT);
INSERT INTO "facilities" VALUES('L01','Block 11','C01','Prison interne et lieu d''exécutions','1940-1945','Cellules, punitions, condamnations et premiers essais de meurtre de masse au Zyklon B','Conservé dans le Mémorial','S06','Établi');
INSERT INTO "facilities" VALUES('L02','Mur des exécutions','C01','Lieu d''exécution','1941-1943 principalement','Exécutions par fusillade dans la cour entre les Blocks 10 et 11','Reconstitué comme lieu de mémoire','S07','Établi');
INSERT INTO "facilities" VALUES('L03','Block 10','C01','Lieu d''expériences médicales','1943-1944','Femmes détenues et victimes d''expériences, notamment de stérilisation','Conservé, accès limité','S12','Établi');
INSERT INTO "facilities" VALUES('L04','Crématoire I et chambre à gaz','C01','Crématoire et chambre à gaz','1940-1943','Crémation puis assassinats par gaz à partir de 1941; chambre à gaz utilisée jusqu''en décembre 1942','Transformé en abri en 1944 puis partiellement reconstitué après-guerre','S06','Établi');
INSERT INTO "facilities" VALUES('L05','Ancienne rampe de marchandises','C02','Lieu d''arrivée et de sélection','1942 à mi-mai 1944','Déchargement des convois et sélections entre Auschwitz I et Birkenau','Lieu historique hors de l''enceinte principale','S03','Établi');
INSERT INTO "facilities" VALUES('L06','Rampe intérieure de Birkenau','C02','Lieu d''arrivée et de sélection','mi-mai 1944 à janvier 1945','Arrivée directe des convois dans Birkenau et sélections','Voie et quai conservés','S03','Établi');
INSERT INTO "facilities" VALUES('L07','Bunker I, petite maison rouge','C02','Chambre à gaz provisoire','mars 1942 à 1943','Ferme transformée utilisée pour le meurtre de masse','Démoli en 1943','S06','Établi');
INSERT INTO "facilities" VALUES('L08','Bunker II, petite maison blanche','C02','Chambre à gaz provisoire','été 1942 à 1943, réutilisée en 1944','Ferme transformée utilisée lors des grandes déportations','Démoli à l''automne 1944; traces du site','S06','Établi');
INSERT INTO "facilities" VALUES('L09','Crématoire II','C02','Chambre à gaz et crématoire','mars 1943 à novembre 1944','Assassinats de masse et crémation','Partiellement démonté puis dynamité en janvier 1945; ruines','S06','Établi');
INSERT INTO "facilities" VALUES('L10','Crématoire III','C02','Chambre à gaz et crématoire','juin 1943 à novembre 1944','Assassinats de masse et crémation','Partiellement démonté puis dynamité en janvier 1945; ruines','S06','Établi');
INSERT INTO "facilities" VALUES('L11','Crématoire IV','C02','Chambres à gaz et crématoire','mars 1943 à octobre 1944','Assassinats de masse et crémation','Incendié lors de la révolte du 7 octobre 1944 puis démantelé; ruines','S09','Établi');
INSERT INTO "facilities" VALUES('L12','Crématoire V','C02','Chambres à gaz et crématoire','avril 1943 au 26 janvier 1945','Assassinats de masse et crémation','Dynamité le 26 janvier 1945; ruines','S06','Établi');
INSERT INTO "facilities" VALUES('L13','Canada, secteur BIIg','C02','Entrepôts des biens spoliés','1943-1945','Tri et stockage des effets volés aux déportés','Entrepôts détruits ou en ruines; objets conservés au Mémorial','S14','Établi');
INSERT INTO "facilities" VALUES('L14','Secteur BIIe','C02','Camp familial des Roma et Sinti','février 1943 au 2 août 1944','Internement de familles roma et sinti','Secteur liquidé; vestiges','S14','Établi');
INSERT INTO "facilities" VALUES('L15','Secteur BIIb','C02','Camp familial de Theresienstadt','septembre 1943 à juillet 1944','Internement temporaire de familles juives principalement tchèques','Secteur liquidé; vestiges','S03','Établi');
INSERT INTO "facilities" VALUES('L16','Secteur BIa et BIb','C02','Camp des femmes','août 1942 à 1945','Détention des femmes transférées d''Auschwitz I et venues de nombreux pays','Vestiges et baraquements conservés','S14','Établi');
INSERT INTO "facilities" VALUES('L17','Buna-Werke','C03','Complexe industriel','1941-1945','Production chimique projetée, caoutchouc synthétique et carburants; travail forcé massif','Site industriel transformé après-guerre','S02','Établi');
CREATE TABLE "french_31000" ("list_id" TEXT PRIMARY KEY, "surname" TEXT, "person_label" TEXT, "matricule" TEXT, "matricule_status" TEXT, "review_status" TEXT, "convoy" TEXT, "departure_date" TEXT, "arrival_date" TEXT, "source_id" TEXT, "source_url" TEXT);
INSERT INTO "french_31000" VALUES('F31000-001','ALIZON','MARIE','31777','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-002','ALIZON','SIMONE','31776','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-003','ALONSO','MARIA','31778','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-004','AMAND','LOUISE épouse de LAVIGNE','31669','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-005','BALITEAU','EMILIA épouse de KERESIT','31783','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-006','BATTAIS','MARGUERITE épouse de STORA','31805','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-007','BERGOEND','JEANNE, CLAIRE, EUGÉNIE épouse de GRANDPERRET','31770','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-008','BESKINE','EUGÉNIA','31837','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-009','BÉZIAU','MARCELLE épouse de LEMASSON','31670','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-010','BLANC','ROSE AMELIE LOUISE','31652','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-011','BOINEAU','SUZANNE épouse de COSTENTIN','31765','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-012','BOLLEAU','HÉLÈNE épouse de ALLAIRE','31807','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-013','BIZARRI','JOSÉPHINE épouse de UMIDO','31848','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-014','BONNARD','YVONNE épouse de BONNARD','','Manquant','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-015','BONNOT','MARIE-LOUISE épouse de JOURDAN','31665','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-016','BORDERIE','JEANNE épouse de ALEXANDRE','31779','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-017','BORSCH','ANNE-MARIE épouse de OSTROWSKA','31801','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-018','BOUCHER','MARGUERITE GERMAINE épouse de CHAVAROC','31796','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-019','BRABANDER','HÉLENE','31695','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-020','BRILLOUET','MARTHE épouse de MEYNARD','31675','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-021','BRUNET','SIMONE, BLANCHE, JULIE épouse de MITERNIQUE','31709','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-022','BUFFARD','SUZANNE épouse de PIERRE','31812','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-023','BUREAU','MARCELLE','31808','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-024','BYEZECK','IRINA épouse de KARCHEWSKA','31698','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-025','CACALY','DENISE épouse de MORET','31820','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-026','CACCIA','LUCIE épouse de MANSUY','31648','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-027','CAILLOT','HENRIETTE épouse de MAUVAIS','31674','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-028','CALMELS','YVONNE épouse de CARRÉ','31760','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-029','CAMUS','OLGA épouse de GODEFROY','31766','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-030','CARDINET','MARGUERITE épouse RICHIER','31840 ?','Incertain','À vérifier','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-031','CHARLES','GERMAINE épouse de CANTELAUBE','31740','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-032','CHAMPION','YVETTE épouse de MARIVAL','31787','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-033','CHARBONNIER','ALIDA épouse de DELASSALE','31659','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-034','CHARUA','CHRISTIANE épouse de BORRAS','31650','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-035','CHUAT','CAMILLE épouse de CHAMPION','31656','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-036','CLÉMENT','SUZANNE épouse de ROZE','31681','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-037','COROT','MARIE épouse de DUBOIS','31693','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-038','COSTON','ADRIENNE épouse de HARDENBERG','31636','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-039','COUPET','SYLVIANE','31804','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-040','COUTEAU','JEANNE','31772','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-041','CRIBIER','MARIE-LOUISE épouse de MORIN','31710','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-042','CZEPOSKA','SOPHIE épouse de BRABANDER','31694','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-043','DAUBIGNY','LÉONIE épouse de SABAIL','31745','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-044','DAURIAT','CHARLOTTE épouse de DECOCK','31756','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-045','DAVY','MADELEINE épouse de ZANI','31744','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-046','DECHAVASSINE','MADELEINE','31639','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-047','DELALANDE','RAYMONDE épouse de SERGENT','31790','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-048','DELBO','CHARLOTTE épouse de DUDACH','31661','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-049','DEMANGEAT','HÉLÈNE épouse de ANTOINE','31775','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-050','DEMIOT','MADELEINE épouse de DAMOUS','31690','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-051','DENIAU','RACHEL','31773','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-052','DENONNE','ANGELE épouse de LEDUC','31841','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-053','DISPER','THÉODORA épouse de VAN DAM','31749','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-054','DISSOUBRAY','MADELEINE épouse de ODRU','31660','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-055','DOIRET','MADELEINE épouse de PERRIOT','31644','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-056','DUDON','AURÉLIE épouse de DUCROS','31746','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-057','DUFOUR','ELISABETH épouse de DUPEYRON','31731','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-058','DUPONT','MARIE-JEANNE','31703','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-059','DUPUIS','CHARLOTTE','31751','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-060','DURBECK','LÉA épouse de LAMBERT','31821','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-061','EIFFES','SIMONE','31764','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-062','FAYS','BERTHE, CÉLINA épouse de SABOURAULT','31683','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-063','FERRY','MARIE, MARCELLE','31816','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-064','FEUILLET','YVETTE','31663','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-065','FLOCH','ROSA, MICHELLE','31854','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-066','FOUGERE','SIMONE épouse de LOCHE','31672','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-067','FOURCADE','GEORGETTE épouse de BRET','31747','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-068','FUGLESANG','MARCELLE','31826','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-069','GADY','THÉRESE épouse de LAMBOY','31800','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-070','GALLOIS','YVONNE, LUCIE','31849','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-071','GANTOU','MARIE-JEANNE épouse de BAUER','31651','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-072','GARDELLE','ALICE épouse de CAILBAULT','31738','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-073','GATET','LAURE','31833','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-074','GIGAND','ANDRÉE','31845','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-075','GIRARD','ANGELE, MARCELLE','31632','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-076','GIRARD','GERMAINE, EMMA','31706','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-077','GODEFROY','AIMÉE épouse de DORIDAT','31767','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-078','GONI','LUZ, HIGINIA épouse de MARTOS','31696','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-079','GOURMELON','MARCELLE','31753','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-080','GOUTAYER','FRANSISKA','31780','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-081','GUAY','MARTHE épouse de HÉBRARD','31832','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-082','GUERIN','CLAUDINE','31664','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-083','GUILLON','AMINTHE née AUGER','31729','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-084','GUITTON','MADELEINE épouse de LAFFITTE','31666','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-085','GUIVARCH','JEANNE épouse de GUYOT','31631','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-086','HASCOET','HÉLENE','31755','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-087','HAUTVAL','ADELAIDE','31802','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-088','HELLERINGER','MARGUERITE épouse de CORRINGER','31657','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-089','HERSCHTEL','JEANNE','','Manquant','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-090','HERVE','JEANNE','31768','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-091','HOUDAYER','YVONNE épouse de SOUCHAUD','31791','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-092','HUDELAINE','JOSÉPHINE épouse de HOUDART','31630','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-093','INCONNU','IDENTITÉ INCONNUE','31836','Établi','À vérifier','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-094','INCONNU','IDENTITÉ INCONNUE','31843','Établi','À vérifier','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-095','JALLAT','DELPHINE épouse de PRESSET','31638','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-096','JOUBERT','MARGUERITE épouse de LERMITE','31835','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-097','JUHEM','SUZANNE','31759','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-098','KARPEN','ANNA épouse de JACQUAT','31827','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-099','KONEFAL','KAROLINA','31707','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-100','KORZENIOWSKA','EUGÉNIE','31700','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-101','KUHN OU KUHNE','LINA','31795','Établi','À vérifier','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-102','LABLE','LUCIE épouse de PECHEUX','31633','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-103','LACHAUME','YVONNE épouse de EMORINE','31662','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-104','LAFABRIER','PAULINE épouse de POMIES','','Manquant','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-105','LAGARDE','GERMAINE épouse de DRAPRON','31809','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-106','LANDY','FABIENNE','31784','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-107','LANGEVIN','HÉLENE épouse de SOLOMON/PARREAUX','31684','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-108','LARCADE','MARIE, MATHILDE épouse de POLITZER','31680','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-109','LARCHER','JEANNE épouse de HUMBERT','31813','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-110','LASNE','SUZANNE','','Manquant','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-111','LAUMONDAIS','EMMA épouse de BOLLEAU','31806','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-112','LE DU','LOUISE épouse de LOCQUET','31828','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-113','LE MAGUER','YVONNE, MARIE épouse de COURTILLAT','31799','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-114','LE MARGUERESSE','RAYMONDE épouse de GEORGES','31750','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-115','LE PORT','ELISABETH','31786','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-116','LEBLOND','SUZANNE épouse de GASCARD','31811','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-117','LEBRETON','LUCIENNE','31692','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-118','LEGROS','RENEE épouse de PITIOT','31629','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-119','LESAGE','MARIE','31671','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-120','LESCURE','BERTHE épouse de LAPEYRADE','31721','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-121','LESTERP','NOÉMIE épouse de DURAND','31727','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-122','LESTERP','RACHEL épouse de FERNANDEZ','31723','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-123','LIEVAL','FERNANDE épouse de LAURENT','31748','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-124','LLUCIA','YVONNE','31704','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-125','LOEB','ALICE','31829','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-126','LUMBROSO','ALICE épouse de VITERBO','31822','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-127','LORIOU','YVONNE','31835','Établi','À vérifier','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-128','LUNG','GISELE épouse de LAGUESSE','31667','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-129','LYET','GEORGETTE épouse de MESSMER','31818','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-130','MACHEFAUD','ANNE-MARIE épouse de EPAUD','31724','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-131','MAGADUR','LOUISE','31673','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-132','MAGUI','SUZANNE, LUCETTE épouse de HERBASSIER','31781','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-133','MARDELLE','MARCELLE épouse de LAURILLOU','31785','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-134','MARIÉ','LOUISE épouse de LOSSERAND','31757','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-135','MAURICE','GERMAINE','31788','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-136','MAURIN','MARGUERITE épouse de VALINA','31732','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-137','MECHAIN','MARIE-LOUISE épouse de COLOMBAIN','31853','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-138','MEME','JULIETTE épouse de POIRIER','31769','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-139','MERCIER','ANGÉLE','31851','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-140','MERLIN','CHARLOTTE épouse de DOUILLOT','31762','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-141','MERLIN','HENRIETTE épouse de L’HUILLIER','31688','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-142','MERU','OLGA épouse de MELIN','31708','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-143','METERREAU','ANTOINETTE épouse de BIBAULT','31771','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-144','MEUGNOT','SUZANNE','','Manquant','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-145','MICHAUD','LUCIENNE épouse de LAUTISSIER','31726','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-146','MICHAUX','RENÉE','31676','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-147','MOLLET','GISÈLE','31677','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-148','MOMON','SUZANNE','31686','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-149','MORIGOT','GERMAINE épouse de PICAN','31679','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-150','MORIN','MADELEINE','','Sans matricule 31000','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-151','MORU','MARIE-LOUISE','31825','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-152','MOUDOULAUD','YVONNE épouse de NOUTARI','31718','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-153','MOUZÉ','GERMAINE épouse de JAUNAY','31782','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-154','NAUDIN','MARIE-THÉRÈSE épouse de FLEURY','31839','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-155','NENNI','VITTORIA épouse de DAUBEUF','31635','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-156','NIZINSKA','ANNA','31702','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-157','NORDMANN','MARIE-ÉLISA épouse de COHEN','31687','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-158','NOYER','SIMONE épouse de DAVID','31658','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-159','OPPICI','TOUSSAINTE','31797','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-160','PAKULA','EUGÉNIE épouse de PAUQUET','31794','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-161','PALLUY','LUCIENNE','31689','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-162','PAPILLON','GABRIELLE épouse de ETHIS','31625','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-163','PARATE','MARCELLE épouse de MOUROT','31819','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-164','PARANT','PAULETTE épouse de PRUNIERES','31654','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-165','PARIS','ALICE épouse de BOULET','','Manquant','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-166','PASSOT','MADELEINE épouse JEGOUZO dite Betty','31668','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-167','PATEAU','YVONNE épouse de PATEAU','31728','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-168','PELLAULT','HÉLÈNE épouse de FOURNIER','31793','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-169','PENNEC','MARIE-JEANNE','31817','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-170','PERINI','DANIELLE épouse de CASANOVA','31655','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-171','PERRAUX','GERMAINE épouse de RENAUDIN','31716','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-172','PICA','AURORE','31742','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-173','PICA','YOLANDE épouse de GILI','31743','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-174','PICARD','YVONNE','31634','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-175','PICHON','SIMONE épouse de BRUGAL','31705','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-176','PINET','CLAUDINE épouse de BLATEAU','31737','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-177','PINTOS','FÉLICIENNE épouse de BIERGE','31734','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-178','PIROU','GERMAINE épouse de BERGER','31842','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-179','PIZZOLI','HENRIETTE née PAPILLON','31626','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-180','PLANTEVIGNE','MADELEINE épouse de NORMAND','31678','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-181','POTET','SUZANNE épouse de MAILLARD','','Manquant','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-182','PROUX','LUCIENNE, PAULETTE épouse de FERRE','31722','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-183','QUATREMAIRE','JAQUELINE','31641','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-184','RAPPENAU','CONSTANCE','31754','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-185','RAQUET','RENÉE épouse de COSSIN','31830','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-186','RAVEAU','LÉONA épouse de BOUILLARD','31815','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-187','RÉAU','GEORGETTE épouse de LACABANNE','31717','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-188','RENAUD','GERMAINE','31682','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-189','RENON','JEANNE épouse de SOUQUE','31739','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-190','RICHARD','YVONNE épouse de CAVÉ','31691','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-191','RICHET','SOPHIE épouse de GIGAND','31844','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-192','RICHIER','ARMANDE','31846 ?','Incertain','À vérifier','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-193','RICHIER','ODETTE','31847 ?','Incertain','À vérifier','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-194','RICHOUX','GABRIELLE épouse de BERGIN','31798','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-195','RIFFAUD','ANNE épouse de RICHON','31741','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-196','RONDEAUX','FRANCE','','Manquant','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-197','ROSTAING','GEORGETTE','31850','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-198','ROSTKOWSKA','FELICIA','31701','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-199','ROUCAYROL','DENISE','31646','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-200','RUJU','ESTERINA','31838','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-201','SABOT','ANNA née GRIES','31713','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-202','SALEZ','RAYMONDE','31645','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-203','SAMPAIX','SIMONE','31758','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-204','SAPIN','MARIE, MATHILDE épouse de CHAUX','31824','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-205','SARDET','YVETTE épouse de GUILLON','31730','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-206','SCHAUB','SOPHIE épouse de LICHT','31803','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-207','SCHMIDT','HENRIETTE épouse de CARRÉ/HEUSSLER','31699','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-208','SEIBERT','ALPHONSINE née GUIARD','31647','Établi','Fiche faite','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-209','SEIGNOLLE','LÉONE','31752','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-210','SERRE','JEANNETTE épouse de LOUIS','31637','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-211','SERRE','LUCIENNE épouse de THEVENIN','31642','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-212','SLUSARCZYK','JULIA','31823','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-213','SOUREIL','MARIE-THÉRÈSE épouse de PUYOOÜ','31720','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-214','TOUBLANC','YVONNE épouse de BOUTGOURG','31792','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-215','TAMISÉ','ANDRÉE','31714','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-216','TAMISÉ','GILBERTE','31715','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-217','THIEBAULT','JEANNE','31640','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-218','THOMAS','MARIE épouse de GABB','','Manquant','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-219','TRAPY','PAULA épouse de RABEAUX','31725','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-220','TRESSARD','ANTOINETTE épouse de BESSEYRE/DELPORTE','31763','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-221','URGON','MARGUERITE épouse de KOTLEREWSKY','31814','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-222','VAN DAM','REYNA','31831','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-223','VAN DER LEE','JAKOBA','31697','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-224','VAN HYFTE','MADELEINE épouse de GALESLOOT PIERRE','31643','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-225','VANDAELE','ROLANDE','31761','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-226','VARAILHON','ALICE','31810','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-227','VAUDER','YVONNE épouse de BLECH','31653','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-228','VERVIN','HELENE épouse de CASTERA','31719','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-229','VEUVE FOURMY','LINE épouse de PORCHER','31789','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-230','VOGEL','MARIE-CLAUDE épouse de VAILLANT-COUTURIER','31685','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
INSERT INTO "french_31000" VALUES('F31000-231','ZANKER','CHARLOTTE épouse de LESCURE','31733','Établi','À faire','Convoi du 24 janvier 1943, dit des 31 000','1943-01-24','1943-01-27','S19','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/');
CREATE TABLE "french_45000" ("list_id" TEXT PRIMARY KEY, "surname" TEXT, "person_label" TEXT, "matricule" TEXT, "matricule_status" TEXT, "review_status" TEXT, "convoy" TEXT, "departure_date" TEXT, "arrival_date" TEXT, "source_id" TEXT, "source_url" TEXT);
INSERT INTO "french_45000" VALUES('F45000-001','ABADA','ROGER','45157','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-002','ABEL','LOUIS, MARIE, VINCENT','45158 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-003','ADAM','MARIUS','45159','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-004','ALBAN','CHARLES, PAUL, DENIS','45160','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-005','ALEXIS','MAURICE, PAUL','45162','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-006','ALESSANDRI','LUCIEN, ERNEST','45161 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-007','ALIGNY','JULIEN','46214','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-008','ALIZARD','MARCEL','45163','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-009','ALLAIRE','LOUIS, JÉRÔME','45164','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-010','ALLAIX','JULES, CLAUDIUS','45165','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-011','ALLOU','ROGER, LÉON, LÉOPOLD','45166','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-012','AMAND','RENÉ, DÉSIRÉ','45167','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-013','AMAROT','ANDRÉ','45168','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-014','AMIARD','ANDRÉ, FERDINAND','45169','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-015','AMIEL','MARIUS, JOSEPH','45170 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-016','ANDRÉ','HENRI, LOUIS, ERNEST','45171','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-017','ANDRÉ','HENRI','46215 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-018','ANDRÉAS','MARCEL LOUIS','45172','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-019','ANDRÉS','ÉMILE, JOSEPH','45173 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-020','ANTONINI','ALEXANDRE','45174','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-021','AONDETTO','RENÉ, MICHEL','45175','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-022','ARBLADE','ALOYSE, NUMA','45176','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-023','ARCHEN','AUGUSTE','45177','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-024','ARMAND','LOUIS, FELIX','46216','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-025','ARNOULD','PIERRE, RAOUL','45178','Établi','Fiche faite','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-026','ASSELINEAU','HENRI, JULES','45179 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-027','ASSIE','FÉLIX','45180 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-028','AUBERT','VICTOR, GASTON','45181','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-029','AUBERTEL','RAOUL','45182 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-030','AUBRY','HENRI, CHARLES','45183','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-031','AUGUSTE','GEORGES','45184','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-032','AUMONT','ROGER, PAUL, JULES','45185 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-033','AUTRET','GEORGES, RENÉ','45186','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-034','AUVRAY','MAURICE','45187','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-035','BACH','JEAN','46217','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-036','BACHELET','CHARLES, VICTOR, CÉCILE','45188','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-037','BADACHE','DAVID','46267','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-038','BAHEU','PAUL','45189','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-039','BAILLON','AMOUR, GILBERT','45190','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-040','BAILLY','PAUL, HENRI','45191','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-041','BAIXAS','CLARIN, BONAVENTURE, MICHEL','45192','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-042','BALAYN','RENÉ','45193','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-043','BALESTRERI','RAYMOND','45194','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-044','BARBE','PAUL','45195','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-045','BARBEROUSSE','DANIEL, HENRI','45196','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-046','BARBIER','MARIUS, EDMOND','45197 ?','Incertain','Fiche faite','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-047','BARDEL','ANDRÉ, EDMOND, FERNAND','45198','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-048','BARTHELEMY','CHARLES, JOSEPH','45199','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-049','BARTHELEMY','FERNAND, AUGUSTE','45200','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-050','BASILLE','MAURICE, PIERRE, CHARLES','45201','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-051','BATAILLARD','EUGÈNE, MARCEL','45203','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-052','BATAILLE','ROGER','45204','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-053','BATÔT','ÉLIE','45205','Établi','Fiche faite','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-054','BATTESTI','JEAN, PAUL','45206 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-055','BAUDRY','RAYMOND, HENRI','45208 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-056','BAUDU','MARCEAU, CAMILLE','45209','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-057','BAUQUIER','LÉON, HENRI, ERNEST','46317 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-058','BAVEUX','GUSTAVE, AUGUSTE, ERNEST','45210','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-059','BEAUCOUSIN','ALBERT','45211 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-060','BEAUDOIN','EUGÈNE, ALEXANDRE','45207','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-061','BEAULIEU','RENÉ','45213','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-062','BEAULIEU','ÉDOUARD','45212 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-063','BEAURE','ALBERT','45214','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-064','BEC','MARCEL, PIERRE','45216','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-065','BECKMAN','JOHAN, FRÉDÉRIK','45218','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-066','BECKMAN','ROBERT, FRANS','45219','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-067','BECUE','ADRIEN, LOUIS, JEAN','45217','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-068','BEDET','LOUIS','45220','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-069','BEDIN','FÉLIX','45221 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-070','BEE','FERNAND, GEORGES','45222 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-071','BELLANGER','LÉON, ADRIEN','45223','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-072','BELLET','LUCIEN','45224','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-073','BENOÎT','ALPHONSE','45225','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-074','BERNARD','CHARLES, PIERRE','45226','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-075','BERNARD','PIERRE, CAMILLE','45227','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-076','BERNHEIM','ARMAND','46268','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-077','BERTAUX','MICHEL','45228 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-078','BERTHELOT','RAYMOND, GEORGES','45229','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-079','BERTHOUT','JEAN, DIT PIERRE','45230','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-080','BERTOLINO','ALBERT, PIERRE','45231','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-081','BERTON','HENRI VICTOR','45232 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-082','BERTOUILLE','MAURICE, AUGUSTE','45233','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-083','BERTRAND','RAOUL, ALPHONSE (DIT CAROTTE)','45234 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-084','BERTRAND','GEORGES','45235 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-085','BESNARD','FERNAND, GASTON','45236','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-086','BESNIER','EUGÈNE','45237','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-087','BESNIER','JOSEPH','45238','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-088','BESSE','ARISTIDE, LOUIS','45239','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-089','BESSE','RENÉ, LOUIS','45240','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-090','BESSOT','MARCEL','45241','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-091','BEUDOU','JEAN','45242','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-092','BEUGNET','ALBERT','45243 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-093','BICHOT','ANDRÉ, JULES, VICTOR','45244','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-094','BIEBER','VICTOR','45245','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-095','BIFFE','JOSEPH','45246 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-096','BIGARE','FERDINAND','45247','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-097','BIGOS','WLADYSLAW','45248 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-098','BIGOT','GEORGES, LÉON, VICTOR','46220 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-099','BILLARD','MAURICE','45249 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-100','BILLOQUET','ÉMILE, CHARLES','46218','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-101','BINARD','JEAN, RAYMOND','45250 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-102','BINER','GEORGES','46219','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-103','BISILLON','ANDRÉ, ARSÈNE','45251','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-104','BLAIS','ROBERT, VICTOR','45253','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-105','BLAIS','RAYMOND','45252 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-106','BLAISE','AUGUSTE','45254','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-107','BLAISON','ANDRÉ, JULES','45255','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-108','BLANCHARD','FERNAND, MAURICE','45256','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-109','BLIN','LUCIEN','45257','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-110','BLIN','RENÉ, MARCEL','45258 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-111','BLUMENFELD','CHAÏM, SZIJA','46269','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-112','BOCCARD','LOUIS, MARIUS','45259','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-113','BOCKEL','HENRI, RENÉ','45260','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-114','BOCQUILLON','EUGÈNE, GASTON, RENÉ','45261 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-115','BODIN','MOISE, ALBERT, JOSEPH','45262 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-116','BOGAERT','PIERRE','45263','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-117','BOISSY','RENÉ','45264','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-118','BOLOGNINI','ANGELO, ERMINO','45265','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-119','BONAZZOLI','CIPRIANI, ERNESTO','45266','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-120','BONDU','ANDRÉ, LOUIS','45267','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-121','BONFILS','ARTHUR, CHARLES, ARISTIDE','45268','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-122','BONHOMME','THÉODORE, HUBERT, VICTOR','45270','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-123','BONHOMME','LUCIEN','45269 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-124','BONNAMY','RAOUL, GABRIEL','45271','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-125','BONNARDIN','EUGÈNE, JEAN','45272 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-126','BONNEL','CHARLES, JEAN, RAYMOND','45273','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-127','BONNET','ÉDOUARD, EUGÈNE','45287 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-128','BONNIFET','ROGER, LOUIS','46221 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-129','BONVALET','ALBERT, JULES, DÉSIRÉ','45274','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-130','BORDY','RENÉ, LOUIS','45275','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-131','BOUBOU','MARCEL','45276','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-132','BOUCHACOURT','ÉMILE, CHARLES','45277','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-133','BOUCHARD','MICHEL, ROGER','45278','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-134','BOUDEAUD','FRANÇOIS','45279','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-135','BOUDOU','RAYMOND','45280','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-136','BOUILLON','FÉLIX','AUCUN','Manquant','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-137','BOUJINSKY','NICOLAS','45281','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-138','BOULANDET','ANDRÉ','45283','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-139','BOULANGER','FERNAND, EDOUARD','45282 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-140','BOULANGER','MARCEL, VINCENT','45284 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-141','BOULANGER','RENÉ','45285 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-142','BOULAY','RENÉ','45286 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-143','BOURDIN','ANDRÉ, LUCIEN','45288 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-144','BOURGET','JEAN','45289','Établi','Fiche faite','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-145','BOURNEIX','PIERRE ROGER','45290','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-146','BOURSET','ÉMILE','45291','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-147','BOUSCAND','JEAN','45292','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-148','BOUSSUGE','FERNAND, ALBERT','45294','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-149','BOUTEILLER','RAYMOND','45293','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-150','BOUYSSOU','FERNAND, ERNEST','46222 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-151','BOYER','MARCEL','45295','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-152','BRAMET','ROBERT, PIERRE','45296 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-153','BRAUD','ALPHONSE','45297 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-154','BREANÇON','ANDRÉ','45298','Établi','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-155','BRENNER','JULES','45300','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-156','BRENNER','LOUIS, JOSEPH','45299 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-157','BRESOLIN','LOUIS','46223 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-158','BRETON','HENRI','46224 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-159','BRIAND','LOUIS, MARIE','45301 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-160','BRIEN','HONORE','46225','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-161','BRIET','MARIUS, LUDOVIC, LOUIS','45302','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-162','BRIOUDES','CLÉMENT','45303','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-163','BRISSET','ROGER, LOUIS','45304','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-164','BRUMM','GEORGES, CHARLES','45305','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-165','BRUN','PAUL, LOUIS','45306 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-166','BRUNET','GEORGES, FERNAND','45307','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-167','BRUNET','LOUIS, EDMOND','45308','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-168','BUDIN','VICTOR','45309','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-169','BUISSON','ABEL, LUCIEN','45310','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-170','BUREAU','ÉMILE, ALFRED','45311','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-171','BUREL','MARCEL','45312 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-172','BURESI','FRANÇOIS','45313','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-173','BURETTE','LÉOPOLD, VICTOR','45314 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-174','BURGHARD','ADRIEN, HENRI','45315 ?','Incertain','À vérifier','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-175','BURTIN','LOUIS','45317','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-176','BURTON','CHARLES, JOSEPH','45316','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-177','BUSARELLO','LÉON','45318','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-178','BUSSY','RENÉ','45319','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-179','BUVAT','LOUIS, ALEXANDRE','45320','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-180','CABARTIER','AUGUSTE MARIUS','45321','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-181','CADET','CLÉMENT, AUGUSTE, ALEXANDRE','45322','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
INSERT INTO "french_45000" VALUES('F45000-182','CADIOU','PIERRE, MARIE','45323','Établi','À faire','Convoi du 6 juillet 1942, dit des 45 000','1942-07-06','','S20','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/');
CREATE TABLE "glossary" ("term_id" TEXT PRIMARY KEY, "term" TEXT, "definition" TEXT, "source_id" TEXT);
INSERT INTO "glossary" VALUES('D01','Auschwitz','Nom allemand d''Oświęcim et nom donné au complexe concentrationnaire établi par l''Allemagne nazie en Pologne occupée.','S01');
INSERT INTO "glossary" VALUES('D02','Birkenau','Nom allemand de Brzezinka; Auschwitz II, principal site de mise à mort du complexe.','S05');
INSERT INTO "glossary" VALUES('D03','Monowitz','Auschwitz III, camp de travail forcé lié au complexe industriel d''IG Farben.','S02');
INSERT INTO "glossary" VALUES('D04','Déporté','Personne contrainte d''être transportée loin de son domicile par une politique de persécution ou de répression. Tous les déportés à Auschwitz ne furent pas enregistrés comme prisonniers.','S04');
INSERT INTO "glossary" VALUES('D05','Prisonnier enregistré','Déporté admis dans le système concentrationnaire, inscrit et généralement doté d''un matricule. Environ 400 000 personnes furent enregistrées à Auschwitz.','S04');
INSERT INTO "glossary" VALUES('D06','Sélection','Tri imposé à l''arrivée ou dans le camp, séparant notamment les personnes destinées au travail forcé de celles immédiatement assassinées.','S03');
INSERT INTO "glossary" VALUES('D07','Matricule','Numéro administratif imposé aux prisonniers enregistrés. Auschwitz fut le seul grand camp nazi où le tatouage systématique du numéro devint une pratique générale.','S15');
INSERT INTO "glossary" VALUES('D08','Sonderkommando','Unités de prisonniers, principalement juifs, forcés de travailler autour des chambres à gaz et crématoires, sous menace constante de mort.','S09');
INSERT INTO "glossary" VALUES('D09','Kommando','Groupe de travail auquel les prisonniers étaient affectés.','S07');
INSERT INTO "glossary" VALUES('D10','Block','Bâtiment ou baraque servant au logement, à l''infirmerie, à la punition ou à d''autres fonctions du camp.','S07');
INSERT INTO "glossary" VALUES('D11','Appell','Appel au cours duquel les prisonniers étaient comptés, souvent dans des conditions meurtrières.','S07');
INSERT INTO "glossary" VALUES('D12','Zyklon B','Pesticide libérant du cyanure d''hydrogène, détourné par les responsables du camp pour assassiner des êtres humains dans les chambres à gaz.','S06');
INSERT INTO "glossary" VALUES('D13','Centre de mise à mort','Installation créée pour assassiner des populations à grande échelle. Birkenau combina cette fonction avec celle de camp de concentration.','S18');
INSERT INTO "glossary" VALUES('D14','Camp de concentration','Lieu d''internement extrajudiciaire, de terreur, de travail forcé et de mort au sein du système concentrationnaire nazi.','S18');
INSERT INTO "glossary" VALUES('D15','Sous-camp','Camp dépendant du complexe principal, souvent installé près d''une mine, d''une usine, d''un chantier ou d''une ferme employant les prisonniers comme travailleurs forcés.','S02');
INSERT INTO "glossary" VALUES('D16','Canada','Surnom donné par les prisonniers aux entrepôts où étaient triés les biens volés aux déportés, le Canada évoquant alors l''abondance.','S14');
INSERT INTO "glossary" VALUES('D17','Muselmann','Terme de camp désignant un prisonnier arrivé à un état d''épuisement et de famine extrêmes; terme historique à employer avec contexte et prudence.','S08');
INSERT INTO "glossary" VALUES('D18','Marches de la mort','Évacuations forcées à pied, par un froid extrême, accompagnées de meurtres et d''innombrables décès.','S10');
INSERT INTO "glossary" VALUES('D19','Zone d''intérêt','Territoire d''environ 40 km² autour du complexe, vidé en grande partie de sa population polonaise et placé sous contrôle du camp.','S03');
INSERT INTO "glossary" VALUES('D20','Convoi','Transport collectif de déportés, souvent par train. Un convoi peut contenir des personnes aux destins différents à l''arrivée.','S03');
INSERT INTO "glossary" VALUES('D21','Victime','Dans les tableaux statistiques, personne assassinée ou morte du fait direct des conditions et politiques du camp. Les chiffres sont souvent des estimations documentées.','S04');
INSERT INTO "glossary" VALUES('D22','Survivant','Personne ayant survécu à Auschwitz, parfois après transferts, marches de la mort et détention dans d''autres camps.','S03');
INSERT INTO "glossary" VALUES('D23','Source primaire','Document ou témoignage produit au moment des faits ou par un témoin direct: registre, liste de transport, lettre, photographie, objet ou déposition.','S16');
INSERT INTO "glossary" VALUES('D24','Source secondaire','Travail historique qui analyse et recoupe des sources primaires.','S04');
INSERT INTO "glossary" VALUES('D25','Niveau de fiabilité','Indication distinguant un fait établi, une estimation, une fourchette, une date approximative ou une information à recouper.','S04');
CREATE TABLE "import_schema" ("field" TEXT, "required" TEXT, "description" TEXT, "example" TEXT);
INSERT INTO "import_schema" VALUES('person_id','oui','Identifiant interne unique et stable','P000001');
INSERT INTO "import_schema" VALUES('last_name','oui si connu','Nom tel qu''il apparaît dans la source, avec variantes séparées','DUPONT');
INSERT INTO "import_schema" VALUES('first_name','oui si connu','Prénom ou prénoms','Marie');
INSERT INTO "import_schema" VALUES('birth_date','non','Date ISO; conserver un champ de précision si partielle','1912-03-08');
INSERT INTO "import_schema" VALUES('birth_place','non','Lieu historique et pays selon les frontières de l''époque','Paris, France');
INSERT INTO "import_schema" VALUES('sex_or_gender_recorded','non','Valeur telle qu''enregistrée, sans extrapolation','F');
INSERT INTO "import_schema" VALUES('nationality_recorded','non','Nationalité indiquée par la source','française');
INSERT INTO "import_schema" VALUES('persecution_category','non','Catégorie historique ou motif de persécution avec contexte','Juive; résistante');
INSERT INTO "import_schema" VALUES('arrest_date','non','Date ISO de l''arrestation','1944-02-10');
INSERT INTO "import_schema" VALUES('arrest_place','non','Lieu de l''arrestation','Lyon');
INSERT INTO "import_schema" VALUES('detention_before','non','Prisons, camps d''internement ou ghettos avant Auschwitz','Drancy');
INSERT INTO "import_schema" VALUES('transport_id','non','Lien vers le convoi ou transport','T00071');
INSERT INTO "import_schema" VALUES('departure_date','non','Date de départ du convoi','1944-04-13');
INSERT INTO "import_schema" VALUES('arrival_date','non','Date d''arrivée à Auschwitz','1944-04-15');
INSERT INTO "import_schema" VALUES('prisoner_number','non','Matricule seulement si la personne fut enregistrée','78651');
INSERT INTO "import_schema" VALUES('number_series','non','Série du matricule, par exemple A, B, Z, EH ou générale','générale femmes');
INSERT INTO "import_schema" VALUES('camp_sector','non','Camp, secteur, block ou sous-camp','Birkenau BIa');
INSERT INTO "import_schema" VALUES('forced_labor','non','Kommando, métier ou entreprise','Bobrek, Siemens');
INSERT INTO "import_schema" VALUES('transfers','non','Liste structurée des transferts ultérieurs','Bergen-Belsen');
INSERT INTO "import_schema" VALUES('fate_status','oui','Assassiné, mort, survivant, transféré, sort inconnu ou à vérifier','Survivante');
INSERT INTO "import_schema" VALUES('death_date','non','Date ISO ou précision documentée','1945-03');
INSERT INTO "import_schema" VALUES('death_place','non','Lieu de décès','Bergen-Belsen');
INSERT INTO "import_schema" VALUES('death_cause','non','Cause seulement si explicitement documentée','typhus');
INSERT INTO "import_schema" VALUES('family_links','non','Identifiants des proches liés','P000002;P000003');
INSERT INTO "import_schema" VALUES('photo_url','non','Lien vers photo authentifiée et conditions d''usage','https://...');
INSERT INTO "import_schema" VALUES('source_id','oui','Source principale','S016');
INSERT INTO "import_schema" VALUES('source_record_reference','non','Cote, page, notice ou numéro d''archive','Notice 12345');
INSERT INTO "import_schema" VALUES('confidence','oui','Établi, probable, incertain, estimation ou à recouper','Établi');
INSERT INTO "import_schema" VALUES('review_status','oui','À saisir, à vérifier, validé ou publié','À vérifier');
INSERT INTO "import_schema" VALUES('reviewed_by','non','Nom du relecteur','Équipe mémoire');
INSERT INTO "import_schema" VALUES('reviewed_date','non','Date de dernière vérification','2026-08-18');
INSERT INTO "import_schema" VALUES('notes','non','Nuances, contradictions entre sources et précautions','Deux orthographes du nom dans les archives');
CREATE TABLE "jewish_origins" ("origin_id" TEXT PRIMARY KEY, "country_or_origin" TEXT, "deported_estimate" INTEGER, "note" TEXT, "source_id" TEXT, "confidence" TEXT);
INSERT INTO "jewish_origins" VALUES('O01','Hongrie, frontières de guerre',430000,'Une autre table détaillée du Mémorial indique 438 000 selon le périmètre retenu.','S04','Estimation très solide');
INSERT INTO "jewish_origins" VALUES('O02','Pologne',300000,'Estimation plus difficile en raison de la destruction et de l''absence de certaines listes.','S05','Estimation de référence');
INSERT INTO "jewish_origins" VALUES('O03','France',69000,'Transports documentés par listes nominatives.','S05','Très solide');
INSERT INTO "jewish_origins" VALUES('O04','Pays-Bas',60000,'Transports notamment depuis Westerbork.','S05','Très solide');
INSERT INTO "jewish_origins" VALUES('O05','Grèce',55000,'Une part majeure venait de Salonique.','S05','Très solide');
INSERT INTO "jewish_origins" VALUES('O06','Bohême-Moravie et Theresienstadt',46000,'Comprend les convois liés au ghetto-camp de Theresienstadt.','S05','Très solide');
INSERT INTO "jewish_origins" VALUES('O07','Camps de concentration et autres origines',34000,'Catégorie agrégée.','S05','Estimation');
INSERT INTO "jewish_origins" VALUES('O08','Slovaquie, frontières de guerre',27000,'Premiers grands transports en mars 1942.','S05','Très solide');
INSERT INTO "jewish_origins" VALUES('O09','Belgique',25000,'Transports notamment depuis Malines.','S05','Très solide');
INSERT INTO "jewish_origins" VALUES('O10','Allemagne et Autriche',23000,'Certains passèrent par Theresienstadt.','S05','Très solide');
INSERT INTO "jewish_origins" VALUES('O11','Yougoslavie',10000,'Frontières d''avant-guerre.','S05','Estimation');
INSERT INTO "jewish_origins" VALUES('O12','Italie',7500,'Premiers transports importants à partir de 1943.','S05','Très solide');
INSERT INTO "jewish_origins" VALUES('O13','Lettonie',1000,'Estimation incluse dans la topographie détaillée du Mémorial.','S05','Estimation');
INSERT INTO "jewish_origins" VALUES('O14','Norvège',690,'Nombre documenté.','S05','Très solide');
CREATE TABLE "medical_experiments" ("experiment_id" TEXT PRIMARY KEY, "responsible" TEXT, "location" TEXT, "period" TEXT, "victim_groups" TEXT, "purpose_claimed" TEXT, "methods" TEXT, "consequences" TEXT, "source_id" TEXT, "confidence" TEXT);
INSERT INTO "medical_experiments" VALUES('M01','Carl Clauberg','Block 10, Auschwitz I; auparavant baraque 30 à Birkenau','fin 1942-1944','principalement femmes juives','Méthode de stérilisation de masse','Injections intra-utérines chimiques et examens radiologiques forcés','Douleurs aiguës, inflammations, lésions, stérilité et décès','S12','Établi');
INSERT INTO "medical_experiments" VALUES('M02','Horst Schumann','baraque 30, secteur BIa de Birkenau','1942-1944','hommes et femmes juifs','Stérilisation par rayons X','Irradiation des organes reproducteurs puis opérations et prélèvements','Brûlures graves, infections, mutilations et décès','S12','Établi');
INSERT INTO "medical_experiments" VALUES('M03','Josef Mengele','Birkenau','1943-1945','jumeaux, enfants, personnes atteintes de nanisme ou d''anomalies héréditaires, Roma et Sinti','Recherches raciales et génétiques','Examens invasifs, prélèvements, infections provoquées et meurtres suivis d''autopsies comparatives','Souffrances, handicaps et assassinats','S12','Établi');
INSERT INTO "medical_experiments" VALUES('M04','Johann Paul Kremer','Auschwitz','1942','prisonniers affamés et malades','Étude des effets de la famine sur l''organisme','Sélection de prisonniers, observations et prélèvements après meurtre','Assassinats pour obtenir des organes et tissus','S12','Établi');
INSERT INTO "medical_experiments" VALUES('M05','Emil Kaschub','Auschwitz','1943-1944','prisonniers','Différencier lésions simulées et pathologiques','Application de substances toxiques provoquant plaies et irritations','Plaies douloureuses, infections et séquelles','S12','Établi');
INSERT INTO "medical_experiments" VALUES('M06','Friedrich Entress, Helmuth Vetter, Eduard Wirths et autres','Hôpitaux du camp','1941-1944','prisonniers atteints de maladies contagieuses','Tester des médicaments pour des firmes et instituts','Administration forcée de préparations expérimentales','Vomissements sanglants, diarrhées, troubles circulatoires et morts','S12','Établi');
INSERT INTO "medical_experiments" VALUES('M07','Plusieurs médecins SS','Hôpitaux du camp','1941-1944','malades, notamment tuberculeux ou atteints de méningite','Formation ou pratique médicale','Opérations sans nécessité médicale, pneumothorax et ponctions lombaires','Complications graves, handicaps et décès','S12','Établi');
CREATE TABLE metadata (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
INSERT INTO "metadata" VALUES('title','Base historique structurée sur le complexe d''Auschwitz');
INSERT INTO "metadata" VALUES('version','1.0');
INSERT INTO "metadata" VALUES('language','fr');
INSERT INTO "metadata" VALUES('date_compilation','2026-08-18');
INSERT INTO "metadata" VALUES('scope_note','Noyau documentaire extensible. Il ne constitue pas une liste nominative exhaustive des quelque 1,3 million de personnes déportées. Chaque ligne doit rester reliée à une source et à un niveau de fiabilité.');
INSERT INTO "metadata" VALUES('editorial_rule','Respecter les personnes, conserver les incertitudes, ne jamais transformer une estimation en chiffre exact et distinguer déporté, prisonnier enregistré, victime, transféré et survivant.');
CREATE TABLE "officials" ("official_id" TEXT PRIMARY KEY, "last_name" TEXT, "first_name" TEXT, "role" TEXT, "period" TEXT, "postwar_fate" TEXT, "source_id" TEXT, "confidence" TEXT);
INSERT INTO "officials" VALUES('R01','Höss','Rudolf','Premier commandant d''Auschwitz; organisateur du complexe','1940-05 à 1943-11; retour en 1944 pour les déportations de Hongrie','Condamné à mort par le Tribunal national suprême polonais et exécuté en 1947 près d''Auschwitz I','S03','Établi');
INSERT INTO "officials" VALUES('R02','Liebehenschel','Arthur','Commandant d''Auschwitz I et supérieur du complexe après la réorganisation','1943-11 à 1944-05','Jugé à Cracovie, condamné à mort et exécuté en 1948','S03','Établi');
INSERT INTO "officials" VALUES('R03','Baer','Richard','Commandant d''Auschwitz I et dernier commandant du complexe unifié','1944-05 à 1945-01','Arrêté en 1960; mort en détention en 1963 avant son procès','S03','Établi');
INSERT INTO "officials" VALUES('R04','Hartjenstein','Fritz','Commandant d''Auschwitz II-Birkenau','1943-11 à 1944-05','Condamné à plusieurs reprises; mort en prison en 1954','S14','Établi');
INSERT INTO "officials" VALUES('R05','Kramer','Josef','Commandant d''Auschwitz II-Birkenau','1944-05 à 1944-11','Condamné à mort au procès de Belsen et exécuté en 1945','S14','Établi');
INSERT INTO "officials" VALUES('R06','Schwarz','Heinrich','Commandant d''Auschwitz III-Monowitz','1943-11 à 1945-01','Condamné à mort par un tribunal militaire français et exécuté en 1947','S14','Établi');
INSERT INTO "officials" VALUES('R07','Mengele','Josef','Médecin SS, sélections et expériences criminelles','1943-1945','Fugitif en Amérique du Sud; mort au Brésil en 1979 sans avoir été jugé','S12','Établi');
INSERT INTO "officials" VALUES('R08','Clauberg','Carl','Médecin responsable d''expériences de stérilisation','1942-1944','Libéré d''URSS en 1955, arrêté en Allemagne de l''Ouest; mort en 1957 avant son procès','S12','Établi');
INSERT INTO "officials" VALUES('R09','Schumann','Horst','Médecin responsable d''expériences de stérilisation par rayons X','1942-1944','Procès interrompu pour raisons médicales; mort en 1983','S12','Établi');
INSERT INTO "officials" VALUES('R10','Kremer','Johann Paul','Médecin SS, sélections et expériences liées à la famine','1942','Condamné à mort en Pologne, peine commuée; condamné ensuite en Allemagne','S12','Établi');
INSERT INTO "officials" VALUES('R11','Mandel','Maria','Cheffe surveillante du camp des femmes','1942-1944','Condamnée à mort au procès d''Auschwitz et exécutée en 1948','S04','Établi, source spécifique à ajouter lors d''un approfondissement');
CREATE TABLE "people" ("person_id" TEXT PRIMARY KEY, "last_name" TEXT, "first_name" TEXT, "birth_date" TEXT, "birth_place" TEXT, "nationality" TEXT, "persecution_category" TEXT, "role_memory" TEXT, "prisoner_number" TEXT, "arrival_date" TEXT, "arrival_context" TEXT, "camp_or_sector" TEXT, "fate" TEXT, "death_date" TEXT, "death_place" TEXT, "source_id" TEXT, "confidence" TEXT, "notes" TEXT);
INSERT INTO "people" VALUES('P001','Frank','Anne','1929-06-12','Francfort-sur-le-Main','allemande puis apatride','Juive','Victime, diariste','non retrouvé dans les sources utilisées','1944-09-05','Dernier transport de Westerbork','Birkenau','Transférée à Bergen-Belsen; morte du typhus en février ou mars 1945','1945-02/03','Bergen-Belsen','S03','Établi, date de décès approximative','Son journal est devenu l''un des témoignages les plus lus sur la persécution des Juifs.');
INSERT INTO "people" VALUES('P002','Levi','Primo','1919-07-31','Turin','italienne','Juif, résistant','Survivant, écrivain et chimiste','174517','1944-02-26','Déporté d''Italie','Monowitz','Survivant, libéré en janvier 1945','1987-04-11','Turin','S03','Établi','Auteur de Si c''est un homme.');
INSERT INTO "people" VALUES('P003','Wiesel','Elie','1928-09-30','Sighet','roumaine puis américaine','Juif','Survivant, écrivain','A-7713','1944-05','Déporté de Sighet avec sa famille','Birkenau puis Monowitz','Évacué vers Buchenwald et survivant','2016-07-02','New York','S03','Établi','Prix Nobel de la paix en 1986.');
INSERT INTO "people" VALUES('P004','Pilecki','Witold','1901-05-13','Olonets','polonaise','Prisonnier politique, résistant','Résistant et témoin clandestin','4859','1940-09-22','Se fait volontairement arrêter pour infiltrer le camp','Auschwitz I','Évadé en avril 1943; exécuté par le régime communiste polonais en 1948','1948-05-25','Varsovie, prison de Mokotów','S09','Établi','Organisa un réseau clandestin et rédigea des rapports sur Auschwitz.');
INSERT INTO "people" VALUES('P005','Kolbe','Maximilian','1894-01-08','Zduńska Wola','polonaise','Prêtre catholique, prisonnier politique','Victime','16670','1941-05','Déporté depuis la prison de Pawiak','Auschwitz I','Se porte volontaire à la place d''un père de famille; tué par injection de phénol après enfermement et famine','1941-08-14','Auschwitz I','S03','Établi','Âgé de 47 ans.');
INSERT INTO "people" VALUES('P006','Vrba','Rudolf','1924-09-11','Topoľčany','slovaque puis canadienne','Juif','Survivant, évadé et témoin','44070','1942-06','Déporté de Slovaquie','Auschwitz et Birkenau','Évadé le 7 avril 1944 avec Alfred Wetzler; survivant','2006-03-27','Vancouver','S03','Établi','Coauteur du rapport Vrba-Wetzler.');
INSERT INTO "people" VALUES('P007','Wetzler','Alfred','1918-05-10','Trnava','slovaque','Juif','Survivant, évadé et témoin','29162','1942-04','Déporté de Slovaquie','Auschwitz et Birkenau','Évadé le 7 avril 1944 avec Rudolf Vrba; survivant','1988-02-08','Bratislava','S03','Établi','Coauteur du rapport Vrba-Wetzler.');
INSERT INTO "people" VALUES('P008','Delbo','Charlotte','1913-08-10','Vigneux-sur-Seine','française','Résistante, prisonnière politique','Survivante, écrivaine','31661','1943-01-27','Convoi des 31 000 depuis Compiègne','Birkenau puis Raisko','Transférée à Ravensbrück et survivante','1985-03-01','Paris','S16','À recouper ligne par ligne dans les archives nominatives','Auteur d''Auschwitz et après.');
INSERT INTO "people" VALUES('P009','Zimetbaum','Mala','1918-01-26','Brzesko','belge d''origine polonaise','Juive','Victime, résistante et évadée','19880','1942-09','Déportée de Belgique','Birkenau','Évasion avec Edek Galiński en juin 1944; reprise et exécutée en septembre 1944','1944-09-15','Auschwitz II-Birkenau','S16','Date couramment admise, vérifier dossier d''archives','Utilisa ses fonctions de messagère et interprète pour aider d''autres prisonnières.');
INSERT INTO "people" VALUES('P010','Gradowski','Zalmen','1910','Suwałki','polonaise','Juif','Victime, membre du Sonderkommando et auteur clandestin','non indiqué ici','1942-12','Déporté du ghetto de Kielbasin','Birkenau','Tué pendant la révolte du Sonderkommando','1944-10-07','Auschwitz II-Birkenau','S09','Établi, certains détails à approfondir','Enterra des manuscrits décrivant les crimes et la vie du Sonderkommando.');
INSERT INTO "people" VALUES('P011','Robota','Róża','1921','Ciechanów','polonaise','Juive','Victime et résistante','non indiqué ici','1942','Déportée de Pologne','Birkenau, travail à l''Union-Werke','Pendue pour participation au réseau ayant fourni des explosifs','1945-01-06','Auschwitz','S03','Établi, date de naissance selon sources variable','L''une des quatre femmes exécutées peu avant la libération.');
INSERT INTO "people" VALUES('P012','Gertner','Ala, Ella','1912-03-12','Będzin','polonaise','Juive','Victime et résistante','non indiqué ici','1943','Déportée depuis le ghetto de Będzin','Birkenau, travail à l''Union-Werke','Pendue pour avoir aidé à transmettre des explosifs','1945-01-06','Auschwitz','S03','Établi','L''une des quatre résistantes exécutées le 6 janvier 1945.');
INSERT INTO "people" VALUES('P013','Safirsztajn','Regina','1915','Będzin','polonaise','Juive','Victime et résistante','non indiqué ici','1943','Déportée de Pologne','Birkenau, Union-Werke','Pendue pour avoir participé au détournement d''explosifs','1945-01-06','Auschwitz','S03','Établi, naissance à préciser','L''une des quatre résistantes exécutées le 6 janvier 1945.');
INSERT INTO "people" VALUES('P014','Wajcblum','Ester','1924','Varsovie','polonaise','Juive','Victime et résistante','non indiqué ici','1943','Déportée de Pologne','Birkenau, Union-Werke','Pendue pour avoir participé au détournement d''explosifs','1945-01-06','Auschwitz','S03','Établi, naissance à préciser','L''une des quatre résistantes exécutées le 6 janvier 1945.');
INSERT INTO "people" VALUES('P015','Szmaglewska','Seweryna','1916-02-11','Przygłów','polonaise','Prisonnière politique','Survivante, écrivaine et témoin','non indiqué ici','1942-10-06','Transport de 47 femmes depuis Radom','Birkenau','Survivante; témoigne au procès de Nuremberg','1992-07-07','Varsovie','S03','Établi','Auteur de La fumée au-dessus de Birkenau.');
INSERT INTO "people" VALUES('P016','Perl','Gisella','1907-12-10','Sighet','roumaine puis américaine','Juive','Survivante et médecin','non indiqué ici','1944-05','Déportée de Sighet','Birkenau','Survivante; médecin et auteure après-guerre','1988-12-16','Herzliya','S03','Établi','Tenta de sauver des femmes enceintes avec les moyens presque inexistants du camp.');
INSERT INTO "people" VALUES('P017','Wongczewski','Dawid','non précisée','Pologne','polonaise','Juif','Première victime décédée enregistrée à Auschwitz','non indiqué ici','1940-06','Parmi les premiers prisonniers polonais','Auschwitz I','Mort pendant ou après un appel punitif de vingt heures','1940-07-06/07','Auschwitz I','S03','Établi, jour précis à cheval sur deux dates','Son nom rappelle que derrière le premier décès se trouvait déjà une vie singulière.');
INSERT INTO "people" VALUES('P018','Wiejowski','Tadeusz','1914','Kołaczyce','polonaise','Prisonnier politique','Premier évadé connu','220','1940-06-14','Premier transport de Tarnów','Auschwitz I','Évadé le 6 juillet 1940; repris plus tard et exécuté','1941','prison de Jasło, selon travaux historiques','S03','Évasion établie; fin de vie à recouper','Son évasion provoqua un appel punitif de vingt heures.');
INSERT INTO "people" VALUES('P019','Jacob','Lili','1926','Bilky','hongroise puis américaine','Juive','Survivante et dépositaire de l''Album d''Auschwitz','A-10862','1944-05-26','Déportation des Juifs de Hongrie','Birkenau puis camps en Allemagne','Survivante; découvre après la libération l''album montrant l''arrivée de son convoi','1999','Miami','S03','Établi, certains détails à recouper','Ses identifications ont rendu des noms et des familles aux visages de l''Album d''Auschwitz.');
INSERT INTO "people" VALUES('P020','Nyiszli','Miklós','1901-06-17','Szilágysomlyó','hongroise','Juif','Survivant, médecin et témoin','A-8450','1944-05/06','Déportation depuis la Hongrie','Birkenau','Survivant; publie un témoignage après-guerre','1956-05-05','Oradea','S16','À vérifier dans la base nominative pour les dates exactes','Forcé de travailler comme médecin légiste sous l''autorité de Mengele.');
INSERT INTO "people" VALUES('P021','Holstein','Denise','1927-02-06','Rouen','française','Juive','Survivante et témoin','non indiqué ici','1944-08','Convoi 77 parti de Drancy le 31 juillet 1944','Birkenau','Transférée dans d''autres camps et survivante',NULL,NULL,'S16','Dossier nominatif à enrichir','Devenue une grande témoin française de la déportation des enfants et des familles.');
INSERT INTO "people" VALUES('P022','Veil','Simone','1927-07-13','Nice','française','Juive','Survivante et femme d''État','78651','1944-04-15','Convoi 71 parti de Drancy le 13 avril 1944','Birkenau puis Bobrek','Évacuée vers Bergen-Belsen et survivante','2017-06-30','Paris','S16','À recouper avec dossier nominatif et archives françaises','Elle consacra une part de sa vie à transmettre la mémoire de la Shoah.');
INSERT INTO "people" VALUES('P023','Kolinka','Ginette','1925-02-04','Paris','française','Juive','Survivante et témoin','78599','1944-04-15','Convoi 71 depuis Drancy','Birkenau','Transférée à Bergen-Belsen et Theresienstadt; survivante',NULL,NULL,'S16','À recouper avec dossier nominatif','A consacré des décennies à témoigner devant les jeunes.');
INSERT INTO "people" VALUES('P024','Loridan-Ivens','Marceline','1928-03-19','Épinal','française','Juive','Survivante, cinéaste et écrivaine','78750','1944-04-15','Convoi 71 depuis Drancy','Birkenau','Transférée à Bergen-Belsen et Theresienstadt; survivante','2018-09-18','Paris','S16','À recouper avec dossier nominatif','Elle a raconté le camp, l''absence de son père et le retour impossible à la vie d''avant.');
INSERT INTO "people" VALUES('P025','Grunwald','Vilma','1903','non précisé ici','tchécoslovaque','Juive','Victime, auteure d''une lettre d''adieu','non indiqué ici','1943','Déportée depuis Theresienstadt avec sa famille','Birkenau BIIb','Assassinée avec son fils John lors de la liquidation du camp familial','1944-07-11','Auschwitz II-Birkenau','S03','Établi, biographie à approfondir','Sa dernière lettre à son mari Kurt demeure l''une des traces les plus bouleversantes du camp familial.');
CREATE TABLE person_documents (
  document_id INTEGER PRIMARY KEY AUTOINCREMENT,
  person_id TEXT REFERENCES people(person_id),
  document_type TEXT NOT NULL,
  title TEXT,
  archive_institution TEXT,
  archive_reference TEXT,
  url TEXT,
  usage_rights TEXT,
  authenticated INTEGER NOT NULL DEFAULT 0 CHECK(authenticated IN (0,1)),
  source_id TEXT REFERENCES sources(source_id),
  notes TEXT
);
CREATE TABLE person_family_links (
  link_id INTEGER PRIMARY KEY AUTOINCREMENT,
  person_id TEXT NOT NULL REFERENCES people(person_id),
  related_person_id TEXT NOT NULL REFERENCES people(person_id),
  relationship TEXT,
  source_id TEXT REFERENCES sources(source_id),
  confidence TEXT,
  UNIQUE(person_id, related_person_id, relationship)
);
CREATE TABLE person_transfers (
  transfer_id INTEGER PRIMARY KEY AUTOINCREMENT,
  person_id TEXT NOT NULL REFERENCES people(person_id),
  transfer_date TEXT,
  from_place TEXT,
  to_place TEXT,
  transport_reference TEXT,
  source_id TEXT REFERENCES sources(source_id),
  confidence TEXT,
  notes TEXT
);
CREATE TABLE review_log (
  review_id INTEGER PRIMARY KEY AUTOINCREMENT,
  entity_table TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  review_status TEXT NOT NULL CHECK(review_status IN ('À saisir','À vérifier','Validé','Publié')),
  reviewer TEXT,
  review_date TEXT,
  notes TEXT
);
CREATE TABLE "sources" ("source_id" TEXT PRIMARY KEY, "institution" TEXT, "title" TEXT, "url" TEXT, "type" TEXT, "language" TEXT, "accessed" TEXT, "reliability" TEXT, "notes" TEXT);
INSERT INTO "sources" VALUES('S01','Mémorial et Musée d''Auschwitz-Birkenau','Histoire du camp','https://www.auschwitz.org/en/history/','Institution mémorielle','en','2026-08-18','Très élevée','Présentation générale officielle.');
INSERT INTO "sources" VALUES('S02','Mémorial et Musée d''Auschwitz-Birkenau','Sous-camps d''Auschwitz','https://www.auschwitz.org/en/history/auschwitz-sub-camps/','Institution mémorielle','en','2026-08-18','Très élevée','Liste, lieux, périodes, employeurs et effectifs repères.');
INSERT INTO "sources" VALUES('S03','United States Holocaust Memorial Museum','Auschwitz: Key Dates','https://encyclopedia.ushmm.org/content/en/article/auschwitz-key-dates','Musée national','en','2026-08-18','Très élevée','Chronologie détaillée, mise à jour en 2026.');
INSERT INTO "sources" VALUES('S04','Mémorial et Musée d''Auschwitz-Birkenau','Informations essentielles et nombres de victimes','https://www.auschwitz.org/en/press/basic-information-on-auschwitz/','Institution mémorielle','en','2026-08-18','Très élevée','Tableaux synthétiques sur les déportés, enregistrés et victimes.');
INSERT INTO "sources" VALUES('S05','Mémorial et Musée d''Auschwitz-Birkenau','Topographie du camp','https://www.auschwitz.org/en/history/kl-auschwitz-birkenau/the-topography-of-the-camp/','Institution mémorielle','en','2026-08-18','Très élevée','Topographie, origine des déportations et statistiques de référence.');
INSERT INTO "sources" VALUES('S06','Mémorial et Musée d''Auschwitz-Birkenau','Chambres à gaz','https://www.auschwitz.org/en/history/auschwitz-and-shoah/gas-chambers','Institution mémorielle','en','2026-08-18','Très élevée','Chronologie et fonction des installations de mise à mort.');
INSERT INTO "sources" VALUES('S07','Mémorial et Musée d''Auschwitz-Birkenau','La vie dans le camp','https://www.auschwitz.org/en/history/life-in-the-camp/','Institution mémorielle','en','2026-08-18','Très élevée','Conditions de détention, hôpitaux, sanctions et travail.');
INSERT INTO "sources" VALUES('S08','Mémorial et Musée d''Auschwitz-Birkenau','Nutrition','https://www.auschwitz.org/en/history/life-in-the-camp/nutrition','Institution mémorielle','en','2026-08-18','Très élevée','Rations et conséquences de la famine.');
INSERT INTO "sources" VALUES('S09','Mémorial et Musée d''Auschwitz-Birkenau','Mutineries de prisonniers','https://www.auschwitz.org/en/history/resistance/prisoner-mutinies','Institution mémorielle','en','2026-08-18','Très élevée','Résistances, évasions et révolte du Sonderkommando.');
INSERT INTO "sources" VALUES('S10','Mémorial et Musée d''Auschwitz-Birkenau','Évacuation finale et liquidation','https://www.auschwitz.org/en/history/evacuation/the-final-evacuation-and-liquidation-of-the-camp','Institution mémorielle','en','2026-08-18','Très élevée','Marches d''évacuation de janvier 1945.');
INSERT INTO "sources" VALUES('S11','Mémorial et Musée d''Auschwitz-Birkenau','Jour de la libération','https://www.auschwitz.org/en/history/liberation/day-of-liberation/','Institution mémorielle','en','2026-08-18','Très élevée','Libération du 27 janvier 1945.');
INSERT INTO "sources" VALUES('S12','Mémorial et Musée d''Auschwitz-Birkenau','Expériences médicales','https://www.auschwitz.org/en/history/medical-experiments/','Institution mémorielle','en','2026-08-18','Très élevée','Cadre général et responsables médicaux.');
INSERT INTO "sources" VALUES('S13','Mémorial et Musée d''Auschwitz-Birkenau','Catégories de prisonniers','https://www.auschwitz.org/en/history/categories-of-prisoners/','Institution mémorielle','en','2026-08-18','Très élevée','Groupes persécutés et catégories administratives.');
INSERT INTO "sources" VALUES('S14','Mémorial et Musée d''Auschwitz-Birkenau','Organisation d''Auschwitz II-Birkenau','https://www.auschwitz.org/en/history/auschwitz-ii/the-organizational-structure','Institution mémorielle','en','2026-08-18','Très élevée','Secteurs internes et réorganisations.');
INSERT INTO "sources" VALUES('S15','Mémorial et Musée d''Auschwitz-Birkenau','Numéros de prisonniers','https://www.auschwitz.org/en/history/victims/prisoner-numbers/','Institution mémorielle','en','2026-08-18','Très élevée','Séries de matricules et système d''enregistrement.');
INSERT INTO "sources" VALUES('S16','Mémorial et Musée d''Auschwitz-Birkenau','Base des victimes et prisonniers','https://victims.auschwitz.org/','Base nominative','multilingue','2026-08-18','Très élevée','Recherche nominative. Les archives demeurent fragmentaires car une grande partie des documents fut détruite.');
INSERT INTO "sources" VALUES('S17','UNESCO','Auschwitz Birkenau, German Nazi Concentration and Extermination Camp 1940-1945','https://whc.unesco.org/en/list/31/','Organisation internationale','en','2026-08-18','Très élevée','Inscription au patrimoine mondial et valeur mémorielle du site.');
INSERT INTO "sources" VALUES('S18','United States Holocaust Memorial Museum','Auschwitz','https://encyclopedia.ushmm.org/content/en/article/auschwitz','Musée national','en','2026-08-18','Très élevée','Vue d''ensemble du complexe concentrationnaire et centre de mise à mort.');
INSERT INTO "sources" VALUES('S19','Mémoire Vive des convois des 45 000 et des 31 000 d''Auschwitz-Birkenau','Les biographies des 31 000 par nom de famille','https://www.memoirevive-bis.org/les-biographies-des-31000-par-nom-de-famille/','Association mémorielle — liste nominative','fr','2026-08-18','Élevée','Liste alphabétique maître utilisée pour les noms et matricules du convoi des femmes du 24 janvier 1943. Les incertitudes affichées par la source sont conservées.');
INSERT INTO "sources" VALUES('S20','Mémoire Vive des convois des 45 000 et des 31 000 d''Auschwitz-Birkenau','Les biographies des 45 000 par nom de famille','https://www.memoirevive-bis.org/les-biographies-des-45000-par-nom-de-famille/','Association mémorielle — liste nominative','fr','2026-08-18','Élevée','Liste alphabétique maître utilisée pour le premier lot des hommes du convoi du 6 juillet 1942. Les points d''interrogation de la source sont conservés.');
INSERT INTO "sources" VALUES('S21','Mémoire Vive des convois des 45 000 et des 31 000 d''Auschwitz-Birkenau','Présentation du convoi du 24 janvier 1943 dit convoi des 31 000','https://www.memoirevive-bis.org/presentation-du-convoi-du-24-janvier-1943-dit-convoi-des-31000/','Association mémorielle — étude de convoi','fr','2026-08-18','Élevée','Contexte historique du convoi de 230 femmes résistantes, arrivé à Birkenau le 27 janvier 1943.');
INSERT INTO "sources" VALUES('S22','Mémoire Vive des convois des 45 000 et des 31 000 d''Auschwitz-Birkenau','Histoire du convoi du 6 juillet 1942 dit convoi des 45 000','https://www.memoirevive-bis.org/histoire-du-convoi-du-6-juillet-1942-dit-convoi-des-45000/','Association mémorielle — étude de convoi','fr','2026-08-18','Élevée','Contexte historique du convoi parti de Compiègne le 6 juillet 1942 avec 1 175 hommes.');
CREATE TABLE "subcamps" ("subcamp_id" TEXT PRIMARY KEY, "name" TEXT, "current_place" TEXT, "start" TEXT, "end" TEXT, "labor" TEXT, "employer" TEXT, "population_reference" TEXT, "population_date" TEXT, "sex" TEXT, "source_id" TEXT);
INSERT INTO "subcamps" VALUES('SC01','Altdorf','Stara Wieś près de Pszczyna','1942','1943','Travaux forestiers','Oberforstamt Pless','10 à 20','non précisée','hommes','S02');
INSERT INTO "subcamps" VALUES('SC02','Althammer','Stara Kuźnia près de Halemba','1944-09','1945-01','Construction d''une centrale thermique','non précisé','486','1945-01-17','principalement hommes','S02');
INSERT INTO "subcamps" VALUES('SC03','Babitz','Babice près d''Oświęcim','1943-03','1945-01','Agriculture sur une ferme SS','SS','159 hommes et environ 180 femmes','1945-01-17 et été 1944','mixte','S02');
INSERT INTO "subcamps" VALUES('SC04','Birkenau, ferme','Brzezinka','1943','1945-01','Agriculture sur une ferme SS','SS','204','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC05','Bismarckhütte','Chorzów','1944-09','1945-01','Production de canons et véhicules blindés','Berghütte-Königs und Bismarckhütte AG','192','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC06','Blechhammer','Sławięcice près de Blachownia Śląska','1944-04','1945-01','Construction d''une usine chimique','O/S Hydrierwerke AG','3 958 hommes et 157 femmes','1945-01-17 et 1944-12-30','mixte','S02');
INSERT INTO "subcamps" VALUES('SC07','Bobrek','Bobrek près d''Oświęcim','1943-12','1945-01','Appareils électriques pour avions et sous-marins','Siemens-Schuckertwerke AG','213 hommes et 38 femmes','1945-01-17 et 1944-12-30','mixte','S02');
INSERT INTO "subcamps" VALUES('SC08','Brünn','Brno, Tchéquie','1943-10','1945-01','Construction pour l''Académie technique SS et police','SS-WVHA Bauleitung Brünn','250 puis 36','1943-10 et 1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC09','Budy, unités agricoles et pénales','Budy près d''Oświęcim','1942-04','1945-01','Agriculture, drainage, étangs et élevage','SS','plusieurs unités, de 313 à environ 400 selon période','1942-1945','mixte, unités séparées','S02');
INSERT INTO "subcamps" VALUES('SC10','Charlottegrube','Rydułtowy','1944-09','1945-01','Extraction de charbon et construction minière','Hermann Göring Werke','833','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC11','Chełmek','Chełmek','1942-10','1942-12','Travaux pour une fabrique de chaussures et réservoir d''eau','Ota Schlesische Schuhwerke, ex-Bata','environ 150','1942','hommes','S02');
INSERT INTO "subcamps" VALUES('SC12','Eintrachthütte','Świętochłowice','1943-05','1945-01','Production d''artillerie antiaérienne','Berghütte-OSMAG et Ost-Maschinenbau','1 297','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC13','Freudenthal','Bruntál, Tchéquie','1944','1945-01','Travail en entreprise et transformation de fruits','Emmerich Machold','301','1944-12-30','femmes','S02');
INSERT INTO "subcamps" VALUES('SC14','Fürstengrube','Wesoła près de Mysłowice','1943-09','1945-01','Extraction de charbon et creusement d''une mine','Fürstengrube GmbH','1 283','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC15','Gleiwitz I','Gliwice','1944-03','1945-01','Réparation de matériel ferroviaire','Reichsbahnausbesserungswerk','1 336','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC16','Gleiwitz II','Gliwice','1944-05','1945-01','Goudron de houille, machines et extension d''usine','Deutsche Gasrusswerke GmbH','740 hommes et 371 femmes','1945-01-17 et 1944-12-30','mixte','S02');
INSERT INTO "subcamps" VALUES('SC17','Gleiwitz III','Gliwice','1944-07','1945-01','Rénovation d''usine, armes, munitions et roues ferroviaires','Zieleniewski-Maschinen und Waggonbau GmbH','609','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC18','Gleiwitz IV','Gliwice','1944-06','1945-01','Baraquements et véhicules militaires','non précisé','444','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC19','Golleschau','Goleszów','1942-07','1945-01','Cimenterie','Ostdeutsche Baustoffwerke et Goleschauer Portland Zement AG','1 008','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC20','Günthergrube','Lędziny','1944-02','1945-01','Mines Piast et Günther','Fürstlich Plessische Bergwerks AG','586','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC21','Harmense','Harmęże près d''Oświęcim','1941-12','1945-01','Élevage de volailles, lapins et poissons','SS','environ 70 hommes et 50 femmes selon unité','1941-1945','mixte, unités séparées','S02');
INSERT INTO "subcamps" VALUES('SC22','Hindenburg','Zabrze','1944-08','1945-01','Production d''armes et munitions','Vereinigte Oberschlesische Hüttenwerke AG','50 hommes et 470 femmes','1945-01-17 et 1944-12-30','mixte','S02');
INSERT INTO "subcamps" VALUES('SC23','Hubertshütte','Łagiewniki','1944-12','1945-01','Travail sidérurgique','Berghütte Königs und Bismarckhütte AG','202','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC24','Janinagrube','Libiąż','1943-09','1945-01','Extraction de charbon, mine Janina','Fürstengrube GmbH','853','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC25','Jawischowitz','Jawiszowice','1942-08','1945-01','Extraction de charbon et travaux de surface','Reichswerke Hermann Göring','1 988','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC26','Kobier','Kobiór','1942','1943','Travaux forestiers','Oberforstamt Pless','158','1943-04-25','hommes','S02');
INSERT INTO "subcamps" VALUES('SC27','Lagischa','Łagisza','1943-09','1944-09','Construction de centrale thermique','Energie-Versorgung Oberschlesien AG','environ 1 000','non précisée','hommes','S02');
INSERT INTO "subcamps" VALUES('SC28','Laurahütte','Siemianowice','1944-04','1945-01','Production d''artillerie antiaérienne','Berghütte-Königs und Bismarckhütte','937','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC29','Lichtewerden','Světlá, Tchéquie','1944-11','1945-01','Filature','G. A. Buhl und Sohn','300','1944-12-30','femmes','S02');
INSERT INTO "subcamps" VALUES('SC30','Mesersitz','Międzyrzecze','1942-10','1943-01','Travaux forestiers','non précisé','non précisé','non précisée','hommes','S02');
INSERT INTO "subcamps" VALUES('SC31','Monowitz','Monowice près d''Oświęcim','1941-04, camp en 1942-10','1945-01','Construction et fonctionnement d''un complexe chimique','IG Farbenindustrie AG','10 223','1945-01-17','principalement hommes','S02');
INSERT INTO "subcamps" VALUES('SC32','Neu-Dachs','Jaworzno','1943-06','1945-01','Mines de charbon et centrale Wilhelm','Energie Versorgung Oberschlesien AG','3 664','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC33','Neustadt','Prudnik','1944-09','1945-01','Usine textile','Schlesische Feinweberei AG','399','1944-12-30','femmes','S02');
INSERT INTO "subcamps" VALUES('SC34','Plawy','Pławy près d''Oświęcim','1944','1945-01','Agriculture sur une ferme SS','SS','138 hommes et environ 200 femmes','1945-01','mixte','S02');
INSERT INTO "subcamps" VALUES('SC35','Radostowitz','Radostowice près de Pszczyna','1942','1943','Travaux forestiers','Oberforstamt Pless','environ 20','non précisée','hommes','S02');
INSERT INTO "subcamps" VALUES('SC36','Raisko','Rajsko','1943-06','1945-01','Horticulture et culture expérimentale de plante à caoutchouc','SS','environ 300','1944','femmes','S02');
INSERT INTO "subcamps" VALUES('SC37','Sonderkommando Kattowitz','Katowice','1944-01','1945-01','Abris antiaériens et baraquements pour la Gestapo','Gestapo','10','non précisée','hommes','S02');
INSERT INTO "subcamps" VALUES('SC38','Sosnowitz I','Sosnowiec','1943-08','1944-02','Rénovation d''un immeuble de bureaux','non précisé','100','non précisée','hommes','S02');
INSERT INTO "subcamps" VALUES('SC39','Sosnowitz II','Sosnowiec','1944-05','1945-01','Aciérie, tubes de canons et obus','Berghütte-Ost-Maschinenbau GmbH','863','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC40','Sośnica','près de Gliwice','1940-07','1940-08','Démolition d''édifices d''un camp de prisonniers de guerre','non précisé','environ 30','1940','hommes','S02');
INSERT INTO "subcamps" VALUES('SC41','SS Hütte Porombka','Międzybrodzie','1940-10','1945-01','Construction et service d''une maison de repos SS','SS','plusieurs dizaines pendant les travaux, moins de 10 femmes au service','variable','mixte','S02');
INSERT INTO "subcamps" VALUES('SC42','SS Bauzug','Karlsruhe, Allemagne','1944-09','1944-10','Déblaiement et réparation des voies ferrées','SS-WVHA Bureau C','environ 500','1944','hommes','S02');
INSERT INTO "subcamps" VALUES('SC43','Trzebinia','Trzebinia','1944-08','1945-01','Extension d''une raffinerie','Erdöl Raffinerie GmbH','641','1945-01-17','hommes','S02');
INSERT INTO "subcamps" VALUES('SC44','Tschechowitz I','Czechowice-Dziedzice','1944-08','1944-09','Déminage de bombes non explosées autour de la raffinerie','Vacuum Oil Company','environ 100','1944','hommes','S02');
INSERT INTO "subcamps" VALUES('SC45','Tschechowitz II','Czechowice-Dziedzice','1944-09','1945-01','Déblaiement et entretien de raffinerie','Vacuum Oil Company','561','1945-01-17','hommes','S02');
CREATE TABLE "timeline" ("event_id" TEXT PRIMARY KEY, "date_start" TEXT, "date_end" TEXT, "date_label" TEXT, "category" TEXT, "title" TEXT, "description" TEXT, "place" TEXT, "source_id" TEXT, "confidence" TEXT);
INSERT INTO "timeline" VALUES('E001','1940-05-04','1940-05-04','4 mai 1940','Administration','Rudolf Höss nommé commandant','Rudolf Höss devient le premier commandant du camp d''Auschwitz.','Auschwitz I','S03','Établi');
INSERT INTO "timeline" VALUES('E002','1940-06-14','1940-06-14','14 juin 1940','Déportation','Premier transport de prisonniers politiques polonais','728 prisonniers détenus à Tarnów arrivent à Auschwitz et subissent le premier appel.','Auschwitz I','S03','Établi');
INSERT INTO "timeline" VALUES('E003','1940-07-06','1940-07-07','6-7 juillet 1940','Évasion et mort','Première évasion réussie et premier décès enregistré','Tadeusz Wiejowski s''évade. Dawid Wongczewski meurt pendant l''appel punitif prolongé.','Auschwitz I','S03','Établi');
INSERT INTO "timeline" VALUES('E004','1940-08','1940-08','août 1940','Infrastructure','Mise en service du crématoire I','Les corps des prisonniers morts ou assassinés commencent à y être brûlés.','Auschwitz I','S03','Établi');
INSERT INTO "timeline" VALUES('E005','1940-10','1940-10','octobre 1940','Résistance','Organisation clandestine de Witold Pilecki','Un réseau clandestin cherche à informer l''extérieur et à aider les prisonniers.','Auschwitz I','S03','Établi');
INSERT INTO "timeline" VALUES('E006','1941-03-01','1941-03-01','1er mars 1941','Expansion','Inspection de Himmler et agrandissement','L''expansion du complexe et une zone d''intérêt d''environ 40 km² sont approuvées.','Complexe d''Auschwitz','S03','Établi');
INSERT INTO "timeline" VALUES('E007','1941-09-03','1941-09-03','3 septembre 1941','Meurtre de masse','Premier meurtre de masse au Zyklon B','Environ 600 prisonniers de guerre soviétiques et 250 prisonniers malades, surtout polonais, sont assassinés dans les caves du Block 11.','Auschwitz I, Block 11','S06','Établi');
INSERT INTO "timeline" VALUES('E008','1941-10','1941-10','octobre 1941','Construction','Début de la construction de Birkenau','Des prisonniers de guerre soviétiques sont employés à la construction du nouveau camp à Brzezinka.','Auschwitz II-Birkenau','S03','Établi');
INSERT INTO "timeline" VALUES('E009','1942-01-25','1942-01-25','25 janvier 1942','Transformation','Changement de fonction de Birkenau','La fonction prévue pour les prisonniers de guerre soviétiques est remplacée par l''incarcération et l''assassinat de Juifs déportés.','Auschwitz II-Birkenau','S03','Établi');
INSERT INTO "timeline" VALUES('E010','1942-03-23','1942-03-23','vers le 23 mars 1942','Meurtre de masse','Bunker I mis en service','Une ferme transformée, dite petite maison rouge, devient une chambre à gaz provisoire.','près de Birkenau','S06','Date approximative');
INSERT INTO "timeline" VALUES('E011','1942-03-26','1942-03-26','26 mars 1942','Déportation','Premiers grands transports de femmes et de Juives slovaques','999 femmes arrivent de Ravensbrück et un premier transport de jeunes femmes juives slovaques est enregistré.','Auschwitz','S03','Établi');
INSERT INTO "timeline" VALUES('E012','1942-03-30','1942-03-30','30 mars 1942','Déportation','Premier convoi de Juifs depuis la France','Plus de 1 000 hommes et adolescents arrivent et sont enregistrés. Très peu survivent.','Auschwitz','S03','Établi');
INSERT INTO "timeline" VALUES('E013','1942-05-04','1942-05-04','4 mai 1942','Sélection','Première sélection interne documentée pour la chambre à gaz','Des prisonniers enregistrés jugés trop malades ou faibles pour travailler sont assassinés.','Birkenau','S03','Établi');
INSERT INTO "timeline" VALUES('E014','1942-07-04','1942-07-04','4 juillet 1942','Sélection','Les sélections des transports deviennent routinières','Les personnes jugées aptes au travail sont enregistrées, les autres sont dirigées vers les chambres à gaz.','Rampe entre Auschwitz I et Birkenau','S03','Établi');
INSERT INTO "timeline" VALUES('E015','1942-07','1942-07','début juillet 1942','Meurtre de masse','Bunker II mis en service','La petite maison blanche, seconde ferme transformée, est utilisée pour assassiner des Juifs.','près de Birkenau','S06','Établi au mois');
INSERT INTO "timeline" VALUES('E016','1942-10','1942-10','octobre 1942','Travail forcé','Monowitz devient un camp permanent','Le camp lié au chantier industriel d''IG Farben entre en fonctionnement.','Auschwitz III-Monowitz','S02','Établi');
INSERT INTO "timeline" VALUES('E017','1943-02','1943-02','février 1943','Persécution','Création du camp familial des Roma et Sinti','Le secteur BIIe reçoit des familles entières déportées à Auschwitz.','Birkenau BIIe','S14','Établi');
INSERT INTO "timeline" VALUES('E018','1943-03','1943-06','mars à juin 1943','Meurtre de masse','Mise en service des crématoires II à V','Les quatre grands complexes de chambres à gaz et crématoires de Birkenau entrent successivement en activité.','Auschwitz II-Birkenau','S03','Établi');
INSERT INTO "timeline" VALUES('E019','1943-04-26','1943-04-27','nuit du 26 au 27 avril 1943','Évasion','Évasion de Witold Pilecki, Jan Redzej et Edward Ciesielski','Pilecki transmet ensuite des rapports sur le camp à la résistance polonaise.','Auschwitz','S09','Établi');
INSERT INTO "timeline" VALUES('E020','1943-09-08','1943-09-08','8 septembre 1943','Déportation','Création du camp familial de Theresienstadt','Des familles juives majoritairement tchèques sont enregistrées et placées dans le secteur BIIb.','Birkenau BIIb','S03','Établi');
INSERT INTO "timeline" VALUES('E021','1943-11-22','1943-11-22','22 novembre 1943','Administration','Division administrative en Auschwitz I, II et III','Le complexe est réorganisé en trois camps principaux dotés de commandements distincts.','Complexe d''Auschwitz','S03','Établi');
INSERT INTO "timeline" VALUES('E022','1944-04-07','1944-04-07','7 avril 1944','Évasion et information','Évasion de Rudolf Vrba et Alfred Wetzler','Leur rapport détaillé sur Auschwitz est diffusé à l''étranger durant l''été 1944.','Auschwitz','S03','Établi');
INSERT INTO "timeline" VALUES('E023','1944-05','1944-05','mi-mai 1944','Infrastructure','Nouvelle rampe intérieure mise en service','Les trains de déportation pénètrent désormais directement dans Birkenau.','Auschwitz II-Birkenau','S03','Établi au mois');
INSERT INTO "timeline" VALUES('E024','1944-05-16','1944-07','à partir du 16 mai 1944','Déportation et meurtre de masse','Déportations massives des Juifs de Hongrie','En quelques semaines, environ 430 000 à 438 000 Juifs sont déportés vers Auschwitz selon le périmètre statistique retenu.','Auschwitz II-Birkenau','S04','Estimation de référence');
INSERT INTO "timeline" VALUES('E025','1944-07-10','1944-07-11','10-11 juillet 1944','Meurtre de masse','Liquidation du camp familial de Theresienstadt','Les femmes et les enfants restants sont assassinés après des sélections pour le travail forcé.','Birkenau BIIb','S03','Établi');
INSERT INTO "timeline" VALUES('E026','1944-08-02','1944-08-02','2 août 1944','Meurtre de masse','Liquidation du camp familial des Roma et Sinti','Environ 4 200 hommes, femmes et enfants sont assassinés au crématoire V.','Birkenau BIIe et crématoire V','S03','Établi');
INSERT INTO "timeline" VALUES('E027','1944-08-11','1944-08-11','11 août 1944','Déportation','Arrivée de civils de l''insurrection de Varsovie','Environ 13 000 civils de Varsovie, dont 1 500 enfants, sont envoyés à Auschwitz au total.','Auschwitz','S03','Estimation de référence');
INSERT INTO "timeline" VALUES('E028','1944-09-05','1944-09-05','5 septembre 1944','Déportation','Arrivée d''Anne Frank et de sa famille','Le dernier transport de Westerbork arrive à Auschwitz. La famille est sélectionnée pour le travail forcé.','Auschwitz II-Birkenau','S03','Établi');
INSERT INTO "timeline" VALUES('E029','1944-10-07','1944-10-07','7 octobre 1944','Résistance','Révolte du Sonderkommando','Des prisonniers juifs incendient le crématoire IV et tentent de s''évader. La révolte est écrasée.','Auschwitz II-Birkenau','S09','Établi');
INSERT INTO "timeline" VALUES('E030','1944-11-26','1944-11-26','26 novembre 1944','Destruction de preuves','Ordre de détruire les crématoires','L''approche de l''Armée rouge accélère le démontage et la destruction des installations.','Auschwitz II-Birkenau','S03','Établi');
INSERT INTO "timeline" VALUES('E031','1945-01-06','1945-01-06','6 janvier 1945','Exécution','Exécution de quatre résistantes juives','Ala Gertner, Róża Robota, Regina Safirsztajn et Ester Wajcblum sont pendues pour avoir fourni des explosifs à la révolte.','Auschwitz','S03','Établi');
INSERT INTO "timeline" VALUES('E032','1945-01-17','1945-01-17','17 janvier 1945','Évacuation','Dernier appel général','Environ 67 000 prisonniers sont comptés dans le complexe et ses sous-camps.','Complexe d''Auschwitz','S03','Estimation très solide');
INSERT INTO "timeline" VALUES('E033','1945-01-17','1945-01-23','17-23 janvier 1945','Évacuation','Marches et transports d''évacuation','Environ 56 000 prisonniers sont contraints de marcher vers l''ouest et environ 2 000 autres sont évacués par train.','Auschwitz vers la Haute-Silésie et l''ouest','S10','Estimation de référence');
INSERT INTO "timeline" VALUES('E034','1945-01-26','1945-01-26','26 janvier 1945','Destruction de preuves','Destruction du crématoire V','Le dernier crématoire encore debout à Birkenau est dynamité.','Auschwitz II-Birkenau','S03','Établi');
INSERT INTO "timeline" VALUES('E035','1945-01-27','1945-01-27','27 janvier 1945','Libération','Libération du complexe','Les soldats de la 60e armée du Premier front ukrainien découvrent environ 7 000 prisonniers dans les camps principaux et Monowitz, beaucoup gravement malades.','Complexe d''Auschwitz','S11','Établi');
CREATE TABLE "transports" ("transport_id" TEXT PRIMARY KEY, "departure_date" TEXT, "arrival_date" TEXT, "origin" TEXT, "transit" TEXT, "deportee_group" TEXT, "count_departed" INTEGER, "count_registered" INTEGER, "count_murdered_on_arrival" INTEGER, "notes" TEXT, "source_id" TEXT, "confidence" TEXT);
INSERT INTO "transports" VALUES('T001','1940-06-14','1940-06-14','Prison de Tarnów','direct','Prisonniers politiques polonais',728,728,0,'Premier transport massif vers Auschwitz.','S03','Établi');
INSERT INTO "transports" VALUES('T002','1942-03','1942-03-26','Ravensbrück','transfert de camp','Femmes détenues, principalement allemandes',999,999,0,'Destinées notamment à devenir prisonnières fonctionnaires dans le camp des femmes.','S03','Établi');
INSERT INTO "transports" VALUES('T003','1942-03','1942-03-26','Poprad, Slovaquie','direct','Jeunes femmes juives slovaques',999,999,0,'Premier transport juif coordonné par le bureau IV B 4 vers Auschwitz.','S03','Établi');
INSERT INTO "transports" VALUES('T004','1942-03-27','1942-03-30','Drancy et Compiègne, France','train','Hommes et adolescents juifs',1112,1112,0,'Premier convoi de Juifs déportés de France vers Auschwitz; effectif exact à confirmer par source française dédiée.','S03','Plus de 1 000 établi; total détaillé à recouper');
INSERT INTO "transports" VALUES('T005','1942-07-15','1942-07-17','Westerbork, Pays-Bas','train','Juifs des Pays-Bas',1137,NULL,NULL,'Premier des deux convois arrivés les 17 et 18 juillet; chiffres détaillés à importer depuis les listes néerlandaises.','S03','Événement établi, effectifs à approfondir');
INSERT INTO "transports" VALUES('T006','1942-08-04','1942-08-05','Malines, Belgique','train','Juifs déportés de Belgique',998,NULL,250,'Premier transport depuis la Belgique; plus de 250 assassinés à l''arrivée selon l''USHMM.','S03','Effectifs arrondis dans la source utilisée');
INSERT INTO "transports" VALUES('T007','1943-01-24','1943-01-27','Compiègne, France','train','230 femmes résistantes et politiques, convoi des 31 000',230,230,0,'Convoi féminin comprenant notamment Charlotte Delbo; source française nominative à relier.','S16','À enrichir par archives françaises');
INSERT INTO "transports" VALUES('T008','1943-10-18','1943-10-23','Rome, Italie','train','Juifs arrêtés à Rome',1022,NULL,NULL,'Premier grand transport de Rome; la vaste majorité est assassinée à l''arrivée.','S03','Événement établi, nombres à recouper');
INSERT INTO "transports" VALUES('T009','1944-04-13','1944-04-15','Drancy, France','convoi 71','Juifs déportés de France',1500,NULL,NULL,'Comprend notamment Simone Veil, Ginette Kolinka et Marceline Loridan-Ivens.','S16','À relier aux listes françaises');
INSERT INTO "transports" VALUES('T010','1944-04-27','1944-04-30','Compiègne, France','convoi dit des tatoués','Résistants et prisonniers politiques',1655,1655,0,'Matricules 184936 à 186590 selon le Mémorial.','S04','Établi');
INSERT INTO "transports" VALUES('T011','1944-05-15','1944-05-16','Hongrie','deux transports','Juifs de Hongrie',6000,500,5500,'Début de la phase la plus meurtrière des déportations de Hongrie; nombres indiqués comme supérieurs à 6 000 et 5 500.','S03','Ordres de grandeur établis');
INSERT INTO "transports" VALUES('T012','1944-07-31','1944-08-03','Drancy, France','convoi 77','Juifs déportés de France, nombreux enfants',1309,NULL,NULL,'Dernier grand convoi parti de Drancy vers Auschwitz; données nominatives à relier à Convoi 77 et aux archives.','S16','À enrichir par source dédiée');
INSERT INTO "transports" VALUES('T013','1944-08-09','1944-09','Ghetto de Łódź','plusieurs transports','Juifs du ghetto de Łódź',67000,NULL,44600,'Environ 67 000 déportés en août-septembre et environ deux tiers assassinés à l''arrivée.','S03','Estimations');
INSERT INTO "transports" VALUES('T014','1944-09-03','1944-09-05','Westerbork, Pays-Bas','dernier transport Westerbork-Auschwitz','Juifs des Pays-Bas, dont la famille Frank',1019,NULL,NULL,'Effectif détaillé à recouper avec les listes de Westerbork.','S03','Événement établi, effectif à confirmer');
INSERT INTO "transports" VALUES('T015','1945-01-17','1945-01-23','Complexe d''Auschwitz','marches vers Wodzisław et Gliwice, puis trains','Prisonniers évacués, majoritairement juifs',58000,NULL,NULL,'Environ 56 000 forcés à marcher et 2 000 évacués par train; de nombreux morts en route.','S10','Estimation de référence');
CREATE TABLE "victim_statistics" ("group_id" TEXT PRIMARY KEY, "group_name" TEXT, "deported_min" INTEGER, "deported_max" INTEGER, "registered_estimate" INTEGER, "murdered_min" INTEGER, "murdered_max" INTEGER, "immediate_murder_estimate" INTEGER, "unit" TEXT, "precision" TEXT, "source_id" TEXT, "notes" TEXT);
INSERT INTO "victim_statistics" VALUES('G01','Juifs',1100000,1100000,200000,1000000,1000000,900000,'personnes','estimations de référence','S04','Environ 85 % de tous les déportés et 91 % des victimes.');
INSERT INTO "victim_statistics" VALUES('G02','Polonais non juifs',140000,150000,130000,70000,75000,NULL,'personnes','fourchette','S05','Prisonniers politiques, résistants, membres de l''intelligentsia, civils raflés et autres personnes persécutées.');
INSERT INTO "victim_statistics" VALUES('G03','Roma et Sinti',23000,23000,21000,20000,21000,NULL,'personnes','estimation','S04','Environ 4 200 hommes, femmes et enfants furent assassinés lors de la liquidation du secteur BIIe le 2 août 1944.');
INSERT INTO "victim_statistics" VALUES('G04','Prisonniers de guerre soviétiques',15000,15000,12000,14000,15000,3000,'personnes','estimation','S05','La plupart moururent par meurtre direct, famine et épuisement.');
INSERT INTO "victim_statistics" VALUES('G05','Autres nationalités et catégories',25000,25000,25000,10000,15000,NULL,'personnes','estimation fragmentaire','S04','Comprend notamment Tchèques, Biélorusses, Français, Allemands, Russes, Yougoslaves, Ukrainiens et d''autres nationalités.');
CREATE INDEX idx_people_name ON people(last_name, first_name);
CREATE INDEX idx_people_number ON people(prisoner_number);
CREATE INDEX idx_people_arrival ON people(arrival_date);
CREATE INDEX idx_timeline_date ON timeline(date_start);
CREATE INDEX idx_subcamps_place ON subcamps(current_place);
CREATE INDEX idx_transports_arrival ON transports(arrival_date);
CREATE INDEX idx_french_31000_name ON french_31000(surname, person_label);
CREATE INDEX idx_french_31000_number ON french_31000(matricule);
CREATE INDEX idx_french_31000_review ON french_31000(review_status, matricule_status);
CREATE INDEX idx_french_45000_name ON french_45000(surname, person_label);
CREATE INDEX idx_french_45000_number ON french_45000(matricule);
CREATE INDEX idx_french_45000_review ON french_45000(review_status, matricule_status);
CREATE VIEW v_victim_totals AS
SELECT
  SUM(deported_min) AS deported_min_total,
  SUM(deported_max) AS deported_max_total,
  SUM(murdered_min) AS murdered_min_total,
  SUM(murdered_max) AS murdered_max_total
FROM victim_statistics;
CREATE VIEW v_people_sources AS
SELECT p.person_id, p.last_name, p.first_name, p.prisoner_number,
       p.fate, p.confidence, s.institution, s.title AS source_title, s.url
FROM people p
LEFT JOIN sources s ON s.source_id = p.source_id;
CREATE VIEW v_timeline_sources AS
SELECT t.event_id, t.date_label, t.category, t.title, t.place,
       t.confidence, s.institution, s.url
FROM timeline t
LEFT JOIN sources s ON s.source_id = t.source_id;
CREATE VIEW v_french_work_queue AS
SELECT '31 000' AS list_name, list_id, surname, person_label, matricule,
       matricule_status, review_status, source_id
FROM french_31000
WHERE review_status <> 'Fiche faite' OR matricule_status <> 'Établi'
UNION ALL
SELECT '45 000' AS list_name, list_id, surname, person_label, matricule,
       matricule_status, review_status, source_id
FROM french_45000
WHERE review_status <> 'Fiche faite' OR matricule_status <> 'Établi';
DELETE FROM "sqlite_sequence";
COMMIT;


-- ============================================================
-- ENRICHISSEMENT DOCUMENTAIRE DU 19 AOÛT 2026
-- Ajouts vérifiés : transferts sortants et backlog de recherche
-- ============================================================

INSERT INTO "sources" VALUES(
'S23',
'Mémorial et Musée d''Auschwitz-Birkenau',
'Destroyed identities — the digital reconstruction of Auschwitz-Birkenau victims'' data',
'https://auschwitz.org/en/museum/news/destroyed-identities-the-digital-reconstruction-of-auschwitz-birkenau-victims-data%2C1398.html',
'Institution mémorielle — recherche archivistique',
'en',
'2026-08-19',
'Très élevée',
'Documente notamment le transfert de 750 hommes d''Auschwitz vers Neuengamme le 25 août 1944 et la reconstruction de 550 identités.'
);

INSERT INTO "sources" VALUES(
'S24',
'Mémorial et Musée d''Auschwitz-Birkenau',
'Volunteer Academy 2025 — prisoners transferred from Auschwitz to Sachsenhausen',
'https://www.auschwitz.org/en/museum/news/volunteer-academy-2025-612-september-call-for-participants%2C1764.html',
'Institution mémorielle — archives',
'en',
'2026-08-19',
'Très élevée',
'Documente le transfert de 2 249 personnes vers Sachsenhausen le 27 octobre 1944; 349 noms conservés sur les listes et 257 dossiers individuels obtenus des Arolsen Archives.'
);

INSERT INTO "timeline" VALUES(
'E036','1944-08-25','1944-08-25','25 août 1944',
'Transfert',
'Transfert de 750 hommes vers Neuengamme',
'750 hommes sont transférés d''Auschwitz vers le camp de Neuengamme. Une reconstruction documentaire a permis d''identifier 550 personnes, contre 270 noms reconnus auparavant.',
'Auschwitz → Neuengamme','S23','Établi pour l''effectif; identités partiellement reconstruites'
);

INSERT INTO "timeline" VALUES(
'E037','1944-10-27','1944-10-27','27 octobre 1944',
'Transfert',
'Transfert de 2 249 prisonniers vers Sachsenhausen',
'2 249 prisonniers sont transférés d''Auschwitz vers Sachsenhausen. 349 noms sont conservés sur les listes existantes et 257 dossiers individuels supplémentaires ont été obtenus des Arolsen Archives pour traitement archivistique.',
'Auschwitz → Sachsenhausen','S24','Établi pour l''effectif; documentation nominative incomplète'
);

INSERT INTO "transports" VALUES(
'T016','1944-08-25','1944-08-25',
'Auschwitz','transfert inter-camps','750 hommes transférés vers Neuengamme',
750,NULL,NULL,
'Transfert sortant : ne pas additionner aux arrivées à Auschwitz. 550 identités reconstruites dans le projet documentaire cité.',
'S23','Effectif établi; identité de tous les transférés non encore reconstruite'
);

INSERT INTO "transports" VALUES(
'T017','1944-10-27','1944-10-27',
'Auschwitz','transfert inter-camps','Prisonniers transférés vers Sachsenhausen',
2249,NULL,NULL,
'Transfert sortant : ne pas additionner aux arrivées à Auschwitz. 349 noms conservés sur les listes; 257 dossiers individuels supplémentaires obtenus des Arolsen Archives.',
'S24','Effectif établi; documentation nominative partielle'
);

CREATE TABLE "research_backlog_2026" (
  "backlog_id" TEXT PRIMARY KEY,
  "priority" INTEGER,
  "corpus" TEXT,
  "period" TEXT,
  "documented_scope" TEXT,
  "integration_status" TEXT,
  "next_action" TEXT,
  "source_url" TEXT,
  "method_note" TEXT
);

INSERT INTO "research_backlog_2026" VALUES(
'RB001',1,'Transfert Auschwitz → Neuengamme','1944-08-25',
'750 hommes; 550 identités reconstruites',
'Événement collectif intégré',
'Importer uniquement les profils individuels publiquement vérifiables et les rapprocher par nom, date de naissance et matricule.',
'https://auschwitz.org/en/museum/news/destroyed-identities-the-digital-reconstruction-of-auschwitz-birkenau-victims-data%2C1398.html',
'550 personnes identifiées ne signifie pas 550 survivants.'
);

INSERT INTO "research_backlog_2026" VALUES(
'RB002',1,'Transfert Auschwitz → Sachsenhausen','1944-10-27',
'2 249 personnes; 349 noms conservés; 257 dossiers obtenus',
'Événement collectif intégré',
'Traiter les dossiers individuels publiés et dédupliquer les 257 dossiers par rapport aux 349 noms déjà connus.',
'https://www.auschwitz.org/en/museum/news/volunteer-academy-2025-612-september-call-for-participants%2C1764.html',
'Ne pas considérer automatiquement les 257 dossiers comme 257 personnes entièrement nouvelles.'
);

INSERT INTO "research_backlog_2026" VALUES(
'RB003',2,'Transports depuis Lwów','1942-1944',
'14 transports signalés dans le rapport annuel 2025',
'À détailler',
'Créer une ligne par transport avec date, effectif, matricules et provenance archivistique.',
'https://www.auschwitz.org/download/gfx/auschwitz/en/defaultstronaopisowa/358/21/1/report_2025.pdf',
'Ne pas extrapoler les données d''un transport aux autres.'
);

INSERT INTO "research_backlog_2026" VALUES(
'RB004',2,'Transports Roma et Sinti','1943-1944',
'176 transports signalés dans le rapport annuel 2025',
'Très partiel',
'Créer un registre transport par transport et relier les personnes de la série Z.',
'https://www.auschwitz.org/download/gfx/auschwitz/en/defaultstronaopisowa/358/21/1/report_2025.pdf',
'Distinguer transport, enregistrement, naissance dans le camp et décès.'
);

INSERT INTO "research_backlog_2026" VALUES(
'RB005',2,'Enfants roms nés à Auschwitz','1943-1945',
'350 dossiers ou enregistrements ajoutés selon le rapport 2025',
'À individualiser',
'Créer un identifiant unique par enfant avant rapprochement avec les autres collections.',
'https://www.auschwitz.org/download/gfx/auschwitz/en/defaultstronaopisowa/358/21/1/report_2025.pdf',
'Contrôle anti-doublon indispensable entre registres de naissance et autres documents.'
);

INSERT INTO "research_backlog_2026" VALUES(
'RB006',2,'Femmes déportées après l''insurrection de Varsovie','1944',
'5 534 femmes signalées dans les enrichissements 2025',
'Partiellement documenté dans le calendrier',
'Croiser les plages de matricules, transports de Pruszków, dates et devenir individuel.',
'https://www.auschwitz.org/download/gfx/auschwitz/en/defaultstronaopisowa/358/21/1/report_2025.pdf',
'Ne pas forcer une date quotidienne lorsque la source ne permet pas de distinguer arrivée et enregistrement.'
);

INSERT INTO "research_backlog_2026" VALUES(
'RB007',3,'Transferts vers Dachau et Flossenbürg','1944-1945',
'Plus de 30 000 identités étudiées dans le projet de reconstruction',
'Backlog',
'Créer une table distincte des transferts inter-camps puis rapprocher les identités.',
'https://auschwitz.org/en/museum/news/destroyed-identities-the-digital-reconstruction-of-auschwitz-birkenau-victims-data%2C1398.html',
'Corpus massif à traiter par lots contrôlés.'
);


-- ============================================================
-- ENRICHISSEMENT NOMINATIF DU 19 AOÛT 2026
-- Profils vérifiés dans la base publique Victims of Auschwitz
-- ============================================================

INSERT INTO "sources" VALUES(
'S25',
'Auschwitz-Birkenau State Museum — Victims of Auschwitz',
'Transport 706 — notice mentionnant Julian Dunikowski, matricule 34904',
'https://victims.auschwitz.org/transports/706',
'Base nominative / transport',
'en',
'2026-08-19',
'Très élevée',
'La notice indique le transfert de Julian Dunikowski vers Neuengamme le 25 août 1944 et sa libération ultérieure.'
);

INSERT INTO "sources" VALUES(
'S26',
'Auschwitz-Birkenau State Museum — Victims of Auschwitz',
'Transport 716 — notices mentionnant Stanisław Bujas 37254 et Jan Reymann 37302',
'https://victims.auschwitz.org/transports/716',
'Base nominative / transport',
'en',
'2026-08-19',
'Très élevée',
'La notice indique le transfert de Stanisław Bujas vers Neuengamme et l''absence de devenir établi. Elle documente aussi Jan Reymann, docteur en chimie et survivant de la guerre.'
);

INSERT INTO "people" VALUES(
'P026','Dunikowski','Julian',NULL,NULL,NULL,
'Prisonnier enregistré à Auschwitz',
'Survivant',
'34904',NULL,
'Présent dans la notice du transport 706',
'Auschwitz puis Neuengamme',
'Transféré à KL Neuengamme le 25 août 1944; libéré ultérieurement',
NULL,NULL,
'S25',
'Élevée',
'Identité, matricule, transfert et libération explicitement mentionnés dans la base officielle.'
);

INSERT INTO "people" VALUES(
'P027','Bujas','Stanisław',NULL,NULL,NULL,
'Prisonnier enregistré à Auschwitz',
'Devenir inconnu',
'37254',NULL,
'Présent dans la notice du transport 716',
'Auschwitz puis Neuengamme',
'Transféré à KL Neuengamme le 25 août 1944; devenir non établi dans la notice consultée',
NULL,NULL,
'S26',
'Élevée',
'Ne pas convertir l''absence de devenir documenté en décès.'
);

INSERT INTO "people" VALUES(
'P028','Reymann','Jan',NULL,NULL,NULL,
'Prisonnier politique / activité clandestine',
'Survivant',
'37302',NULL,
'Arrêté le 28 juillet 1941 pour appartenance à une organisation clandestine',
'Auschwitz; destination ultérieure à contrôler',
'Survécut à la guerre',
NULL,NULL,
'S26',
'Élevée pour identité, matricule, profession et survie; moyenne pour rattachement précis au transfert du 25 août',
'Docteur en chimie. Le rattachement exact à la destination Neuengamme doit rester à vérifier ligne par ligne tant que la notice publique complète n''est pas accessible.'
);

CREATE TABLE IF NOT EXISTS "nominative_verification_log" (
  "verification_id" TEXT PRIMARY KEY,
  "person_id" TEXT,
  "verified_on" TEXT,
  "verified_field" TEXT,
  "value" TEXT,
  "source_id" TEXT,
  "confidence" TEXT,
  "note" TEXT
);

INSERT INTO "nominative_verification_log" VALUES
('NV001','P026','2026-08-19','prisoner_number','34904','S25','Élevée','Matricule explicitement associé à Julian Dunikowski.'),
('NV002','P026','2026-08-19','transfer','Auschwitz → Neuengamme, 1944-08-25','S25','Élevée','Transfert explicitement mentionné.'),
('NV003','P026','2026-08-19','fate','libéré','S25','Élevée','La notice indique qu''il fut plus tard libéré.'),
('NV004','P027','2026-08-19','prisoner_number','37254','S26','Élevée','Matricule explicitement associé à Stanisław Bujas.'),
('NV005','P027','2026-08-19','transfer','Auschwitz → Neuengamme, 1944-08-25','S26','Élevée','Transfert explicitement mentionné.'),
('NV006','P027','2026-08-19','fate','non établi','S26','Élevée','La notice précise que son devenir n''a pas pu être établi.'),
('NV007','P028','2026-08-19','prisoner_number','37302','S26','Élevée','Matricule explicitement associé à Jan Reymann.'),
('NV008','P028','2026-08-19','profession','docteur en chimie','S26','Élevée','Profession explicitement mentionnée.'),
('NV009','P028','2026-08-19','fate','survivant de la guerre','S26','Élevée','La notice indique qu''il survécut à la guerre.');


-- ============================================================
-- ENRICHISSEMENT NOMINATIF SUPPLÉMENTAIRE — 19 AOÛT 2026
-- ============================================================

INSERT INTO "sources" VALUES
('S27','Auschwitz-Birkenau State Museum — Victims of Auschwitz','Transport 707','https://victims.auschwitz.org/transports/707','Base nominative / transport','en','2026-08-19','Très élevée','Documente notamment Franciszek Cyron/Cyran 34938, survivant.'),
('S28','Auschwitz-Birkenau State Museum — Victims of Auschwitz','Transport 709','https://victims.auschwitz.org/transports/709','Base nominative / transport','en','2026-08-19','Très élevée','Documente notamment Władysław Bentkowski 35694, transféré à Ravensbrück et survivant.'),
('S29','Auschwitz-Birkenau State Museum — Victims of Auschwitz','Transport 717','https://victims.auschwitz.org/transports/717','Base nominative / transport','en','2026-08-19','Très élevée','Documente Jan Malec 39215, Zdzisław Marczyński 39216 et Antoni Szlęk 39223.'),
('S30','Auschwitz-Birkenau State Museum — Victims of Auschwitz','Transport 821','https://victims.auschwitz.org/transports/821','Base nominative / transport','en','2026-08-19','Très élevée','Documente Jakub Przewłocki 149937, transféré à Sachsenhausen et employé par Siemens.'),
('S31','Auschwitz-Birkenau State Museum — Victims of Auschwitz','Transport 662','https://victims.auschwitz.org/transports/662','Base nominative / transport','en','2026-08-19','Très élevée','Documente Ludwik Dudek 22467, envoyé à Sachsenhausen le 29 octobre 1944.');

INSERT INTO "people" VALUES
('P029','Cyron / Cyran','Franciszek',NULL,NULL,NULL,'Prisonnier enregistré à Auschwitz','Survivant','34938',NULL,'Présent dans la notice du transport 707','Auschwitz; autres camps à détailler','Survécut à la guerre',NULL,NULL,'S27','Élevée','La notice officielle signale la variante orthographique Cyron/Cyran.'),
('P030','Bentkowski','Władysław',NULL,NULL,NULL,'Prisonnier enregistré à Auschwitz','Survivant','35694',NULL,'Présent dans la notice du transport 709','Auschwitz puis Ravensbrück','Transféré à Ravensbrück le 12 juin 1944; vécut jusqu''à la libération',NULL,NULL,'S28','Élevée','Transfert et survie documentés.'),
('P031','Kofin','Fryderyk',NULL,NULL,NULL,'Prisonnier enregistré à Auschwitz','Survivant','37278',NULL,'Présent dans la notice du transport 716','Auschwitz puis Sachsenhausen puis Buchenwald','Vécut jusqu''à la libération',NULL,NULL,'S26','Élevée','Chaîne de transfert inter-camps explicitement documentée.'),
('P032','Malec','Jan',NULL,NULL,NULL,'Prisonnier enregistré à Auschwitz','Survivant','39215',NULL,'Présent dans la notice du transport 717','Auschwitz puis Neuengamme','Survécut; se sauva lors du naufrage du Cap Arcona dans la baie de Lübeck',NULL,NULL,'S29','Élevée','Épisode du Cap Arcona documenté par la base officielle.'),
('P033','Marczyński','Zdzisław',NULL,NULL,NULL,'Prisonnier enregistré à Auschwitz','Survivant','39216',NULL,'Présent dans la notice du transport 717','Auschwitz puis Dachau','Vécut jusqu''à la liberté',NULL,NULL,'S29','Élevée','Destination Dachau et survie documentées.'),
('P034','Szlęk','Antoni',NULL,NULL,NULL,'Prisonnier enregistré à Auschwitz','Survivant','39223',NULL,'Présent dans la notice du transport 717','Auschwitz puis Ravensbrück','Transféré le 12 juin 1944 et libéré à Ravensbrück',NULL,NULL,'S29','Élevée','Transfert et libération documentés.'),
('P035','Przewłocki','Jakub',NULL,NULL,NULL,'Prisonnier enregistré à Auschwitz','Devenir inconnu','149937',NULL,'Présent dans la notice du transport 821','Auschwitz puis Sachsenhausen','Transféré à Sachsenhausen; devenir non établi dans l''extrait consulté',NULL,NULL,'S30','Élevée pour transfert et emploi; devenir non établi','Employé par Siemens comme professionnel qualifié.'),
('P036','Dudek','Ludwik',NULL,NULL,NULL,'Prisonnier enregistré à Auschwitz','Devenir inconnu','22467',NULL,'Présent dans la notice du transport 662','Auschwitz puis Sachsenhausen','Envoyé à Sachsenhausen le 29 octobre 1944; devenir non établi dans l''extrait consulté',NULL,NULL,'S31','Élevée pour transfert','Ne pas déduire le devenir sans source supplémentaire.');

INSERT INTO "nominative_verification_log" VALUES
('NV010','P029','2026-08-19','prisoner_number','34938','S27','Élevée','Matricule de Franciszek Cyron/Cyran.'),
('NV011','P029','2026-08-19','fate','survivant de la guerre','S27','Élevée','Survie explicitement mentionnée.'),
('NV012','P030','2026-08-19','prisoner_number','35694','S28','Élevée','Matricule de Władysław Bentkowski.'),
('NV013','P030','2026-08-19','transfer','Auschwitz → Ravensbrück, 1944-06-12','S28','Élevée','Transfert explicitement daté.'),
('NV014','P030','2026-08-19','fate','vécut jusqu''à la libération','S28','Élevée','Survie explicitement mentionnée.'),
('NV015','P031','2026-08-19','prisoner_number','37278','S26','Élevée','Matricule de Fryderyk Kofin.'),
('NV016','P031','2026-08-19','transfer','Auschwitz → Sachsenhausen → Buchenwald','S26','Élevée','Chaîne inter-camps explicitement mentionnée.'),
('NV017','P031','2026-08-19','fate','vécut jusqu''à la libération','S26','Élevée','Survie explicitement mentionnée.'),
('NV018','P032','2026-08-19','prisoner_number','39215','S29','Élevée','Matricule de Jan Malec.'),
('NV019','P032','2026-08-19','transfer','Auschwitz → Neuengamme','S29','Élevée','Transfert explicitement mentionné.'),
('NV020','P032','2026-08-19','fate','survivant du Cap Arcona','S29','Élevée','La notice indique qu''il réussit à se sauver du navire en train de couler.'),
('NV021','P033','2026-08-19','prisoner_number','39216','S29','Élevée','Matricule de Zdzisław Marczyński.'),
('NV022','P033','2026-08-19','transfer','Auschwitz → Dachau','S29','Élevée','Destination explicitement mentionnée.'),
('NV023','P033','2026-08-19','fate','vécut jusqu''à la liberté','S29','Élevée','Survie explicitement mentionnée.'),
('NV024','P034','2026-08-19','prisoner_number','39223','S29','Élevée','Matricule d''Antoni Szlęk.'),
('NV025','P034','2026-08-19','transfer','Auschwitz → Ravensbrück, 1944-06-12','S29','Élevée','Transfert explicitement daté.'),
('NV026','P034','2026-08-19','fate','libéré à Ravensbrück','S29','Élevée','Libération explicitement mentionnée.'),
('NV027','P035','2026-08-19','prisoner_number','149937','S30','Élevée','Matricule de Jakub Przewłocki.'),
('NV028','P035','2026-08-19','transfer','Auschwitz → Sachsenhausen','S30','Élevée','Transfert explicitement mentionné.'),
('NV029','P035','2026-08-19','work','Siemens — professionnel qualifié','S30','Élevée','Emploi explicitement mentionné; aucun devenir n''est déduit.'),
('NV030','P036','2026-08-19','prisoner_number','22467','S31','Élevée','Matricule de Ludwik Dudek.'),
('NV031','P036','2026-08-19','transfer','Auschwitz → Sachsenhausen, 1944-10-29','S31','Élevée','Transfert explicitement daté.');
