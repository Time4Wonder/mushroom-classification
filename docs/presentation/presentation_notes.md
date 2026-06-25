# Sprechernotizen – Präsentation "Mushroom Classification"

## Überblick

Diese Notizen enthalten Hintergrundinformationen, die **nicht auf den Folien stehen**,
aber für das Verständnis und für mögliche Nachfragen in der Diskussion wichtig sind.

---

## Folie 1 – Titel

**Keine besonderen Notizen.** Kurz vorstellen: Name, Thema, Betreuer.

---

## Folie 2 – Problemstellung

**Hintergrund zum Datensatz:** Der UCI Mushroom Dataset wurde 1987 von der
Audubon Society zusammengestellt, basierend auf dem *Field Guide to North American
Mushrooms*. Enthält 22 Merkmale von 8.124 Pilzen (23 Arten der Gattungen *Agaricus*
und *Lepiota*). Jeder Pilz wurde von Mykologen bestimmt → Ground Truth ist
verlässlich.

**Warum asymmetrische Kosten relevant:** Die Aufgabenstellung (Ch. 5) betont, dass
man Metriken sinnvoll wählen muss. Im Vortrag darauf hinweisen, dass eine hohe
Accuracy nichts nützt, wenn die 0,3% Fehler tödlich sind.

**Diskussionsfrage für Nachfragen:** "Hätten wir nicht auch F1-Score nehmen können?"
→ Antwort: F1-Score gewichtet Precision und Sensitivity, aber nicht Specificity.
Unser Fokus liegt auf Specificity (giftige korrekt erkennen), also ist F1 ungeeignet.

---

## Folie 3 – Datensatz

**Warum 22 Merkmale?** Ursprünglich standen 22 + Zielvariable zur Verfügung.
veil_type (Velum-Typ: partial/universal) war konstant – alle Pilze haben ein
Teilvelum (Ring). Gemäß Ch. 3.1 (Entfernen irrelevanter Daten) wurde es entfernt.

**Nominale Merkmale:** Anders als metrische Merkmale (Größe, Gewicht) sind alle
Merkmale kategorial. Das schließt Verfahren aus, die Distanzen brauchen (k-NN, SVM).

**stalk_root:** Die 30 fehlenden Werte (kodiert als "?") wurden mit dem Modalwert
"bulbous" (knollig) imputiert. Der Modalwert ist hier sinnvoller als der Median,
da wir nominale Daten haben.

---

## Folie 4 – Reduced-Variante

**Detaillierte Begründung für die Reduced-Variante:**

1. **odor (Geruch):** Cramér's V = 0,971 – fast perfekte Trennung. Aber: Geruch
   ist subjektiv (manche Menschen riechen bestimmte Stoffe nicht), ältere oder
   getrocknete Pilze verlieren den Geruch. Ein praktisches Bestimmungssystem
   sollte nicht auf Geruch angewiesen sein.

2. **spore_print_color (Sporenpulverfarbe):** Ein Sporenabdruck braucht 2–6 Stunden
   und feuchtes Papier. Kein Pilzsammler macht das im Wald. Im Prinzip ein
   Labor-Merkmal, nicht für Feldbestimmung geeignet.

3. **gill_color (Lamellenfarbe):** Wurde **nicht** entfernt, weil:
   - Lamellenfarbe ist ein Standard-Merkmal in jeder Pilzbestimmung
   - Auch bei frischen Pilzen gut erkennbar
   - Cramér's V = 0,68 – stark, aber ohne perfekte Trennung auf allen Levels

**Diskussionsfrage:** "Hätten Sie auch Korrelation zwischen Features prüfen sollen?"
→ Ja, stalk_surface_above/below_ring sind stark korreliert (0,59 vs. 0,58). Für
LogReg ein Problem (Multikollinearität), für Bäume nicht.

---

## Folie 5 – Cramér's V

**Berechnung:** Cramér's V ist ein Maß für den Zusammenhang zweier nominaler
Variablen. Basiert auf Chi-Quadrat-Test, normiert auf [0,1]. V = 1 bedeutet:
die Merkmalsausprägung bestimmt die Klasse eindeutig. V = 0 bedeutet: kein
Zusammenhang.

**Interpretation der Werte:**
- odor (0,971): Praktisch perfekt. 7 von 9 Levels determinieren die Klasse.
- spore_print_color (0,753): Sehr stark. 4 von 9 Levels determinieren.
- gill_color (0,681): Stark, aber nicht deterministisch.
- stalk_shape (0,102): Fast kein Zusammenhang – überraschend, weil manche
  Pilzarten typische Stielformen haben.

**Plot:** Der Cramér's V Plot (balkendiagramm) zeigt, wie rapide die Werte
abfallen – von 0,97 (odor) auf 0,10 (stalk_shape). Die ersten 3 Merkmale
dominieren deutlich.

---

## Folie 6 – Perfekte Indikatoren

**Warum gibt es perfekte Indikatoren?** Der Datensatz bildet reale biologische
Bestimmungsregeln ab. Beispiel: Ein Pilz mit oranger Lamellenfarbe und
fischigem Geruch gehört mit hoher Wahrscheinlichkeit zu einer giftigen Art.
Diese Merkmale sind nicht zufällig, sondern evolutionär/ökologisch bedingt.

**Bedeutung für Modelle:**
- **LogReg:** Ein perfekter Indikator führt zur nicht existierenden ML-Schätzung
- **Tree:** Ein perfekter Indikator erzeugt sofort einen Blattknoten → kein Problem
- **RF:** Gleiches Prinzip wie Tree, nur robuster durch Mittelung

**Praktischer Hinweis:** Wenn Sie in der Praxis auf perfekte Separierung stoßen,
ist Firth's penalisierte Likelihood (logistf-Paket) oder LASSO-Regression der
Standard-Lösungsweg.

---

## Folie 7 – Train/Test + CV

**Warum 70/30?** Typischer Split in der ML-Praxis (70% Training, 30% Test).
Bei sehr großen Datensätzen (1M+) nimmt man 90/10 oder 99/1. Bei 8.124 Instanzen
ist 70/30 üblich. Bei zu kleinem Testsatz (z.B. 80/20) wäre die Varianz der
Metriken zu hoch.

**Warum Stratifikation?** Die Klassen sind nahezu balanciert (51,8% / 48,2%).
Trotzdem stratifizieren wir, um sicherzustellen, dass der Split nicht zufällig
eine Klasse überrepräsentiert. Gerade bei kleineren Datensätzen wichtig.

**set.seed(467):** Reproduzierbarkeit ist in der ML-Praxis essentiell. Ohne
fixierten Seed sind Ergebnisse nicht reproduzierbar.

**1-SE-Regel (Ch. 6.3):** Wähle nicht das komplexeste Modell mit minimalem
CV-Fehler, sondern das **einfachste**, dessen Fehler noch innerhalb von
einer Standardabweichung liegt. Das reduziert Overfitting ohne signifikanten
Genauigkeitsverlust.

---

## Folie 8 – Logistische Regression

**Perfect Separation mathematisch (für Nachfragen):**

Die Likelihood-Funktion der LogReg ist:
L(β) = ∏ p(x_i)^y_i · (1-p(x_i))^(1-y_i)

mit p(x) = 1 / (1 + e^(-x^Tβ))

Bei perfekter Trennung gibt es eine Hyperebene, die alle y=0 von y=1 trennt.
Dann kann man die Koeffizienten in Richtung dieser Hyperebene immer weiter
vergrößern → die Likelihood wird dabei immer größer → Maximum existiert nicht.

**Praktisches Beispiel:** Wenn alle Pilze mit orange Lamellen essbar sind,
muss der Koeffizient für "gill_color=orange" unendlich groß sein, damit
p(edible|orange) = 1 wird. Der Algorithmus kann kein "unendlich" berechnen.

**Warum konvergiert glm nicht?** Der IRLS-Algorithmus (Iteratively Reweighted
Least Squares) bricht ab, weil die Gewichtsmatrix singular wird (eine perfekte
Vorhersage hat Gewicht ≈ 0 für die Residuen → Division durch Null).

**Diskussion:** Sagt ruhig, dass LogReg hier als **Negativbeispiel** dient –
das ist didaktisch wertvoll. Es zeigt, dass man Methoden nicht blind anwenden
darf, sondern die Datenstruktur verstehen muss.

---

## Folie 9 – Decision Tree: Funktionsweise

**Gini-Index (Ch. 4.1):** Der Baum splittet so, dass der Gini-Index minimiert
wird. Gini = 1 - Σ p_k², wobei p_k der Anteil der Klasse k im Knoten ist.
Gini = 0 → reiner Knoten (nur eine Klasse). Gini maximal → gleichverteilte
Klassen.

**Beispiel:** Ein Split auf gill_color mit 12 Levels erzeugt 12 Kinder. Gini
misst, wie rein diese Kinder sind. Der Split mit dem größten Gini-Gewinn wird
gewählt.

**Warum keine Perfect Separation in Bäumen:** Der Baum bildet keine
Linearkombination, sondern Partitionen. Ein Level, das perfekt trennt, wird
als Blattknoten enden → fertig. Keine Koeffizienten, keine Division durch Null.

**Binäre Splits:** rpart erzeugt binäre Splits (ja/nein). Für nominale Merkmale
mit k Levels wird das Level in zwei Gruppen geteilt. Das ist der Standard und
funktioniert gut.

---

## Folie 10 – cp-Tuning

**Wie printcp() zu lesen ist:**

| cp | nsplit | rel error | xerror | xstd |
|---|---|---|---|---|
| 0,60124 | 0 | 1,00000 | 1,00000 | 0,01375 |
| 0,00109 | 19 | 0,00803 | 0,00547 | 0,00141 |
| 0,00100 | 20 | 0,00693 | 0,00693 | 0,00159 |

- **cp** (Spalte 1): Der Complexity Parameter für diese Zeile
- **nsplit** (Spalte 2): Anzahl der Splits (= Baumgröße)
- **rel error** (Spalte 3): Fehler auf Trainingsdaten
- **xerror** (Spalte 4): Mittlerer CV-Fehler über 10 Folds
- **xstd** (Spalte 5): Standardabweichung des CV-Fehlers

Die letzte Zeile (cp = 0,001) ist der größtmögliche Baum. rpart hat intern
20 Splits versucht.

**1-SE-Regel angewandt:**
- Min xerror = 0,00547 (bei 19 Splits)
- xstd = 0,00141
- Schwelle = 0,00547 + 0,00141 = 0,00688
- Der nächstkleinere Baum (18 Splits) hat xerror > 0,00688 → fällt raus
- Also bleibt es bei cp = 0,00109 (19 Splits)

**Grafik:** Der plotcp()-Befehl visualisiert das. Die gepunktete Linie ist die
1-SE-Schwelle.

**Diskussionsfrage:** "Warum nicht den exakten minimalen cp nehmen?"
→ Antwort: Der minimale cp ist oft überangepasst (Overfitting). Die 1-SE-Regel
ist eine Heuristik, die einen robusteren, einfacheren Baum liefert.

---

## Folie 11 – Cost-sensitive Tree

**Loss Matrix detailliert:**

Die Matrix in rpart wird übergeben als:
```r
cost <- matrix(c(0, 1,
                 10, 0), nrow = 2, byrow = TRUE)
```

Zeilen = wahre Klasse, Spalten = vorhergesagte Klasse.
Erste Zeile/Spalte = erste Klassenstufe (= "edible").
- cost[1,1] = edible → edible: 0 (korrekt)
- cost[1,2] = edible → poisonous: 1 (harmloser Fehler)
- cost[2,1] = poisonous → edible: 10 (tödlicher Fehler)
- cost[2,2] = poisonous → poisonous: 0 (korrekt)

**Warum 10:1 und nicht 100:1?** Die Wahl des Verhältnisses ist eine
Modellentscheidung. Ein Verhältnis von 10:1 bedeutet: "Ein tödlicher Fehler
ist 10× schlimmer als ein harmloser." Ein höheres Verhältnis (50:1, 100:1)
würde noch aggressiver FP vermeiden, aber mehr FN (essbar→giftig) erzeugen.
Hier hat 10:1 bereits 0 FP geliefert → kein höheres Verhältnis nötig.

**Ergebnis:** Der Cost-sensitive Baum hat die Wurzel auf `stalk_color_above_ring`
gesplittet (nicht `gill_color`). Das ist kein Zufall: Der Baum sucht zuerst
nach Merkmalen, die die Giftklasse sicher erkennen (= hohe Specificity).
stalk_color_above_ring hat 3 Ausprägungen (gray, orange, red), die zu 100%
essbar sind – alle anderen werden als potentiell giftig weiterverfolgt.

---

## Folie 12 – Baumvisualisierung

**Lesen des rpart.plot:**
- Jeder Knoten zeigt: die vorhergesagte Klasse (edible/poisonous), den
  Anteil der Klasse im Knoten, und den Anteil der Daten im Knoten
- Farben: grün = edible, rot = poisonous (je kräftiger, desto reiner)
- Die Kanten zeigen die Split-Bedingung

**Wichtige Knoten im Cost-sensitive Tree:**
- Knoten 2: stalk_color_above_ring = gray,orange,red → 100% edible (620 Pilze)
- Knoten 6: population = abundant,numerous → 100% edible (555 Pilze)
- Knoten 14: stalk_color_below_ring = gray,red → 100% edible (295 Pilze)
- Knoten 511: ring_type = evanescent,large,none → 100% poisonous (2141 Pilze)

**Hinweis:** Der Baum ist zu komplex, um jede Regel in der Präsentation zu
lesen. Zeigen Sie die Struktur und heben Sie die ersten Splits hervor.

---

## Folie 13 – Random Forest

**Hintergrund für mtry-Tuning:**
- mtry = Anzahl der Merkmale, die an jedem Split zufällig ausgewählt werden
- Standard für Klassifikation: sqrt(p) = sqrt(19) ≈ 4
- Tuning-Suche: mtry = 2..12 per 10-fold CV (manual, kein caret)
- mtry = 11 gewählt (höhere Werte besser, weil starke Prädiktoren)

**Ergebnisse (überraschend perfekt):**
- RF Reduced: **0 FP, 0 FN, 100% Accuracy** — besser als jeder Einzelbaum
- Das liegt am Ensemble-Effekt: 500 Bäume mitteln sich zu einer robusteren
  Entscheidungsgrenze; jeder Baum sieht andere Feature-Kombinationen und
  findet subtile Muster
- OOB-Fehler: 0,00% — kein Overfitting
- AUC: 1,000 (perfekt)

**Variable Importance:**
- gill_color (691), gill_size (389), stalk_surface_above_ring (303),
  ring_type (286), population (247) — bestätigt Cramér's V
- veil_color (0,83), gill_attachment (0,19) — praktisch irrelevant

**Warum RF besser ist als der Einzelbaum:**
1. 500 Bäume statt 1 → niedrigere Varianz
2. Bootstrap → jede Beobachtung wird im Mittel von ~315 Bäumen gesehen
3. Zufällige Merkmalsauswahl → Bäume sind unkorreliert → robustere Vorhersage
4. Kein Pruning → tiefe Bäume können spezifische Subgruppen lernen, ohne
   zu overfitten (OOB-Fehler bestätigt das)

**Diskussion:** Der Trade-off: RF Reduced ist nach Metriken das beste Modell,
aber nicht interpretierbar. Der Cost-sensitive Tree ist erklärbar (Regeln).

---

## Folie 14 – Modellvergleich

**Die LogReg-Werte in Klammern:** 1262 FP, 0 FN – das sind keine validen
Metriken, weil das Modell nicht konvergiert ist. Trotzdem stehen sie in der
Tabelle, um zu zeigen, wie schlimm es werden kann, wenn man ein ungeeignetes
Modell anwendet.

**Interpretation der Tabelle:**
- **RF Reduced: 0 FP, 0 FN, 100%** — perfekte Klassifikation nach Metriken
- Cost-sensitive Tree: 0 FP, 20 FN, 99,18% — **beste Wahl für Praxis**
- Standard Tree: 2 FP, 4 FN, 99,75% — fast perfekt, aber 2 tödliche Fehler

**Warum zwei Modelle empfehlen?**
- RF Reduced: beste Metriken, aber nicht erklärbar (Blackbox)
- Cost-sensitive Tree: fast so gut, aber voll interpretierbar (Regeln)
- Im Anwendungskontext "Pilzsammler" ist Erklärbarkeit entscheidend
- In der Forschung (z.B. Merkmalsanalyse) wäre RF erste Wahl

---

## Folie 15 – Fazit

**Kernbotschaften für den Vortrag:**

1. **LogReg ≠ Allheilmittel** – Perfect Separation ist kein Implementierungsfehler,
   sondern ein Datenproblem. Das zu erkennen zeigt Methodenverständnis.

2. **Cost-sensitive Learning** ist State-of-the-Practice für unbalancierte
   Kosten. rpart unterstützt es nativ – kein Extra-Paket nötig.

3. **Zwei Modelle, zwei Stärken:** RF Reduced liefert perfekte Metriken,
   Cost-sensitive Tree liefert Erklärbarkeit. Der Trade-off ist zentral in der ML-Praxis.

4. **Datensatz verstehen** ist wichtiger als Modell-Tuning. Ohne die Analyse der
   perfekten Indikatoren hätte man nicht verstanden, warum LogReg scheitert.

**Mögliche Nachfragen vom Prof:**
- "Hätten Sie auch andere Verfahren getestet?" → Ja, k-NN und SVM wurden
  wegen nominaler Daten ausgeschlossen, LASSO wegen Fokus auf Variablenselektion.
- "Warum haben Sie gill_color nicht auch entfernt?" → Es ist ein Standard-
  Bestimmungsmerkmal, frisch gut erkennbar. Die Stärke des Zusammenhangs
  (Cramér's V = 0,68) ist hoch, aber nicht deterministisch.
- "Haben Sie die Features auf Redundanz geprüft?" → Ja, cap_color und
  stalk_color sind teilweise redundant, aber das stört Tree-Methoden nicht.
- "RF ist perfekt – warum empfehlen Sie trotzdem den Cost-sensitive Tree?"
  → Erklärbarkeit ist im Anwendungskontext entscheidend. Wenn ein Modell
  einen Pilz als giftig einstuft, muss der Pilzsammler verstehen *warum*.
  RF kann das nicht liefern. Zudem: RF erreicht 100% auf *diesem* Testset,
  aber in der Praxis (neue Pilzarten) ist ein erklärbares Modell robuster.
- "Haben Sie RF auch mit Cost-sensitive Learning versucht?" → randomForest
  unterstützt keine Loss Matrix direkt. Man könnte die Klassenschwellen
  verschieben (classwt), aber das haben wir nicht getestet, da RF bereits
  0 FP ohne Anpassung erreicht.

---

## Folie 16 – Ende

**Keine besonderen Notizen.** Danke sagen, Fragen einladen.
Ggf. auf den Code auf GitHub verweisen.
