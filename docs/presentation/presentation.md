---
marp: true
theme: uncover
class:
  - lead
  - invert
---

# Maschinelles Lernen – Mushroom Classification

**Binäre Klassifikation: essbar vs. giftig**

UCI Mushroom Dataset · TH Deggendorf · SS2026

---

<!-- note: Hier erklären, dass die Aufgabenstellung "3 alternative supervised learning methods" aus Kapitel 4–9 der Vorlesung verlangt. Wir haben LogReg (Kap 4.1), Decision Tree (Kap 4.1) und Random Forest (Kap 4.1/Ensemble) gewählt. Der Datensatz ist der UCI Mushroom Dataset, ein Standard-Datensatz für Klassifikation mit 22 nominalen Merkmalen. -->

## Problemstellung

**Ziel:** Unterscheidung essbarer und giftiger Pilze anhand von 22 Merkmalen (Hutform, Farbe, Geruch, Lamellen, Stiel, Lebensraum, …)

### Entscheidend: Asymmetrische Kosten

| Fehler | Bedeutung | Konsequenz |
|---|---|---|
| **FP** (giftig → essbar) | Giftpilz als essbar eingestuft | ⚠️ **Tödlich** |
| FN (essbar → giftig) | Essbarer Pilz als giftig eingestuft | Pilz wird nicht gegessen (harmlos) |

> **Kernerkenntnis:** Ein Klassifikator muss zuerst **Specificity** (Richtig-negativ-Rate) maximieren – und nicht Accuracy. Ein falsch-positiver Pilz (giftig→essbar) darf nicht vorkommen.

---

<!-- note: Der Datensatz hat 8.124 Instanzen, 22 nominale Merkmale + Zielvariable. Jedes Merkmal hat 2–12 Ausprägungen (kodiert als einzelne Buchstaben). Fehlende Werte gibt es nur in stalk_root (30x "?"), die mit dem Modalwert bulbous (häufigste Ausprägung) imputiert wurden. veil_type war konstant (nur "partial") und wurde gemäß Kap 3.1 (Entfernen irrelevanter Daten) gestrichen. -->

## Datensatz

| Kennzahl | Wert |
|---|---|
| Instanzen | 8.124 |
| Merkmale | 22 nominal (2–12 Levels) |
| Zielvariable | `class`: edible (51,8%) / poisonous (48,2%) |
| Fehlende Werte | nur `stalk_root` (30× `?`) → modalimputiert |
| Konstant | `veil_type` → entfernt (Ch. 3.1) |

### Zwei Varianten für die Modellierung

| Variante | Features | Entfernt | Begründung |
|---|---|---|---|
| **Full** | 21 | `veil_type` | Alle verfügbaren Merkmale |
| **Reduced** | 19 | + `odor`, `spore_print_color` | **Pilzsammler-Szenario:** Geruch ist subjektiv/inkonsistent, Sporenabdruck im Feld nicht praktikabel |

---

<!-- note: Die reduzierte Variante ist das realistischere Szenario. Ein Pilzsammler im Wald riecht zwar manchmal, aber nicht jeder riecht gleich gut, ältere Pilze verlieren den Geruch. Einen Sporenabdruck macht niemand im Feld – das dauert Stunden. gill_color (Lamellenfarbe) bleibt drin, weil es ein Standard-Bestimmungsmerkmal in jedem Pilzbuch ist. -->

## Deskriptive Analyse: Cramér's V

**Cramér's V** misst die Stärke des Zusammenhangs jedes Merkmals mit `class`.

| Rang | Merkmal | Cramér's V | Interpretation |
|---|---|---|---|
| 1 | **odor** (Geruch) | **0,971** | ⚡ nahezu perfekte Trennung |
| 2 | **spore_print_color** (Sporenfarbe) | 0,753 | sehr stark |
| 3 | **gill_color** (Lamellenfarbe) | 0,681 | stark |
| 4 | stalk_surface_above_ring | 0,588 | mäßig |
| 5 | stalk_surface_below_ring | 0,575 | mäßig |
| 6 | gill_size | 0,540 | mäßig |
| … | … | … | |
| 21 | stalk_shape | 0,102 | sehr schwach |

> **Kernerkenntnis:** `odor` dominiert mit 0,971. 7 von 9 Geruchsausprägungen sind **100%-Indikatoren** – das macht den Datensatz für manche Modelle zu einfach (und für andere kaputt).

---

<!-- note: Die perfekten Indikatoren sind zentral für das Verständnis, warum LogReg scheitert. Zeigen Sie hier: jedes dieser Features hat Ausprägungen, die zu 100% mit einer Klasse einhergehen. Das ist biologisch plausibel – bestimmte Pilzarten haben zwingend bestimmte Merkmale. Der Datensatz wurde bewusst so konstruiert. -->

## Perfekte Indikatoren – das Kernproblem

Mehrere Merkmale haben Ausprägungen, die die Klassen **perfekt trennen**:

| Merkmal | 100% essbar | 100% giftig |
|---|---|---|
| `odor` | almond, anise | creosote, fishy, foul, musty, pungent, spicy |
| `spore_print_color` | buff, orange, purple, yellow | green |
| `gill_color` | orange, red | buff, green |
| `stalk_color_above_ring` | gray, orange, red | (none – aber bis 96,4%) |
| `stalk_color_below_ring` | gray, orange, red | buff, cinnamon, yellow |

Selbst in der **Reduced-Variante** (19 Features, ohne `odor` + `spore_print_color`) existieren noch perfekt trennende Levels (`gill_color`, `stalk_color`).

> **Kernerkenntnis:** Der Datensatz wurde für regelbasierte Bestimmung konzipiert. Probabilistische Modelle (LogReg) kommen damit nicht zurecht – Tree-Methoden schon.

---

<!-- note: Ch. 5.5 der Vorlesung: Der Datensatz wird in Trainings- und Testdaten aufgeteilt. Der Testdatensatz wird NUR für die finale Evaluation verwendet. Tuning (Parameterwahl) erfolgt ausschließlich über die 10-fold CV auf dem Trainingsdatensatz. Verweis auf Ch. 6.1: "Durch das Tunen auf dem Testdatensatz haben wir den Testdatensatz als Validierungsdatensatz missbraucht." -->

## Train/Test Split & Cross-Validation

**Stratifizierter 70/30 Split** (set.seed(467), Ch. 5.5)

| Datensatz | Zeilen | edible | poisonous | Anteil |
|---|---|---|---|---|
| Gesamt | 8.124 | 4.208 | 3.916 | 51,8% / 48,2% |
| Training (70%) | 5.687 | 2.946 | 2.741 | 51,8% / 48,2% |
| Test (30%) | 2.437 | 1.262 | 1.175 | 51,8% / 48,2% |

### Tuning mit 10-fold Cross-Validation (Ch. 6.3)

- Nur auf dem **Trainingsdatensatz**
- 10 Folds → 9 trainieren, 1 validieren → mitteln
- **1-SE-Regel:** Wähle den einfachsten Modellparameter, dessen Fehler innerhalb von 1 Standardabweichung des Minimums liegt
- Testdaten bleiben bis zur finalen Evaluation **unangetastet**

> **Kernerkenntnis:** Klassenproportionen bleiben durch Stratifikation erhalten. Testdaten sind "heilig" – keine Parameterwahl auf ihnen.

---

<!-- note: glm (Ch. 4.1) ist das einfachste aller Verfahren. Schätze Koeffizienten via Maximum Likelihood, sigmoid am Ende. Die logistische Regression ist baugleich mit einem einzelnen Neuron (Perzeptron mit Sigmoid-Aktivierung). Die Koeffizienten geben an, wie stark jedes Merkmal in Richtung "essbar" zeigt. -->

## Methode 1: Logistische Regression (glm)

### Perfect Separation – das Modell versagt

Die logistische Regression schätzt **alle Koeffizienten gleichzeitig** per Maximum Likelihood. Existiert eine Linearkombination, die die Daten perfekt trennt, geht der Schätzer gegen ±∞.

**Ergebnis auf beiden Varianten:**

| Aspekt | Full (21 Feat.) | Reduced (19 Feat.) |
|---|---|---|
| Konvergenz | ❌ *`glm.fit: algorithm did not converge`* | ❌ *gleicher Fehler* |
| Ursache | `odor` (0,971) | `gill_color`, `stalk_color` (perfekte Levels) |
| Residual Deviance | ~0 (degeneriert) | ~0 (degeneriert) |
| Vorhersagen | 100% falsch | 100% falsch |

**Lehrbuchbezug (Ch. 4.1):** *"Bei perfekter Trennung existiert der ML-Schätzer nicht."*

> **Kernerkenntnis:** glm ist für diesen Datensatz **ungeeignet** – nicht wegen Implementierungsfehlern, sondern wegen der Datenstruktur (deterministische Merkmals-Giftigkeit-Beziehungen). Die logistische Regression ist kein "Allheilmittel". Als Negativbeispiel didaktisch wertvoll.

---

<!-- note: Entscheidungsbäume (Ch. 4.1) partitionieren den Merkmalsraum rekursiv. An jedem Knoten wird das Merkmal gewählt, das den Gini-Index maximiert – also die "Reinheit" der Klassen nach dem Split. Der Vorteil: Es wird nie ein Koeffizient geschätzt, sondern nur geschaut: "Sind die Daten auf dieser Seite eher essbar oder giftig?" Wenn ein Level perfekt trennt (wie gill_color = orange → immer essbar), wird sofort ein Blattknoten erzeugt – problemlos. -->

## Methode 2: Decision Tree (rpart)

### Warum Bäume funktionieren

| Aspekt | glm (LogReg) | rpart (Tree) |
|---|---|---|
| Schätzung | Simultane ML-Schätzung | Gierige Split-Suche |
| Perfekte Trennung | ❌ Bricht die Optimierung | ✅ Erzeugt sofort Blattknoten |
| Nominale Merkmale | Dummy-Kodierung nötig | Nativ verarbeitet |
| Ergebnis | Koeffizienten | Wenn-Dann-Regeln |

### cp-Tuning via 10-fold CV (Ch. 6.3)

```
   cp       nsplit   xerror    xstd
   0.60124   0      1.00000   0.01375
   0.12003   1      0.39876   0.01084
   0.00109  19      0.00547   0.00141   ← min xerror
   0.00100  20      0.00693   0.00159
```

- **Minimaler CV-Fehler:** 0,00547 (19 Splits, cp = 0,00109)
- **1-SE-Regel** bestätigt cp = 0,00109 → **38 Splits**, 11 von 19 Merkmalen genutzt

---

<!-- note: Der Cost-sensitive Ansatz ist State-of-the-Practice für asymmetrische Kosten. rpart erlaubt das Setzen einer Loss-Matrix über parms = list(loss = ...). Das ist kein Hack, sondern vorgesehener Mechanismus. Der Baum wächst so, dass FP (giftig → essbar) 10x härter bestraft werden als FN (essbar → giftig). In der Praxis würde man das Kostenverhältnis mit Fachexperten (Mykologen) abstimmen. -->

## Cost-sensitive Decision Tree

### Loss Matrix: FN tödlich, FP harmlos

```
           vorhergesagt edible   vorhergesagt poisonous
edible          0 (korrekt)          1 (FP = harmlos)
poisonous      10 (FN = TOD)         0 (korrekt)
```

**Interpretation:** Ein giftiger Pilz, der als essbar eingestuft wird, kostet **10× mehr** als umgekehrt. Der Baum minimiert diese gewichteten Kosten.

### Vergleich: Standard vs. Cost-sensitive

| Metrik | Standard (1:1) | Cost-sensitive (10x) | ✅ |
|---|---|---|---|
| **FP (giftig → essbar = TOD)** | **2** | **0** | **Cost** |
| FN (essbar → giftig = harmlos) | 4 | 20 | |
| Accuracy | 99,75% | 99,18% | |
| Specificity | 99,83% | **100,00%** | **Cost** |

> **Kernerkenntnis:** Der Cost-sensitive Tree hat **0 tödliche Fehler**. Dafür werden 20 essbare Pilze fälschlich als giftig eingestuft (harmlos). Für die Praxis die **bessere Wahl**.

---

<!-- note: Der erste Split geht auf stalk_color_above_ring (nicht gill_color!). Der Cost-sensitive Baum sucht zuerst nach Merkmalen, die giftige Pilze sicher erkennen. Alle Pilze mit grauem/orangenem/rotem Stiel werden sofort als essbar eingeordnet – diese Stielfarben kommen bei giftigen Pilzen praktisch nie vor. Der Baum ist mit 68 Splits deutlich komplexer als der Standardbaum (38 Splits). -->

## Baumvisualisierung (Cost-sensitive Tree)

![Cost-sensitive Decision Tree](../plots/tree_plot.png)

- **Wurzel:** `stalk_color_above_ring` (nicht `gill_color`!)
- **68 Splits**, 15 von 19 Merkmalen genutzt
- 100% Specificity: **alle giftigen Pilze korrekt erkannt**

---

<!-- note: Random Forest (Kap 4.1 als Ensemble-Erweiterung von Bäumen) zieht B Bootstrap-Stichproben und trainiert auf jeder einen Baum. Beim Split wird nicht über alle Merkmale optimiert, sondern über eine zufällige Teilmenge (mtry). Das reduziert die Korrelation zwischen den Bäumen und verbessert die Generalisierung. OOB (Out-of-Bag) Fehler ersetzen die CV. Vorteil: meist beste Accuracy. Nachteil: nicht mehr voll interpretierbar (Blackbox). Trotzdem kann man Variable Importance berechnen. -->

## Methode 3: Random Forest

### Idee (Ch. 4.1, Ensemble-Erweiterung)

- **B** Bootsrap-Stichproben aus den Trainingsdaten
- Auf jeder Stichprobe einen Entscheidungsbaum wachsen (ungekürzt, groß)
- Beim Split: nur eine **zufällige Teilmenge** der Merkmale prüfen (`mtry`)
- Vorhersage: **Majority Vote** aller Bäume

### Vorteile

| Aspekt | Einzelbaum | Random Forest |
|---|---|---|
| Varianz | Hoch (instabil) | ✅ **Niedrig** (mittelt über Bäume) |
| Overfitting | Anfällig (tiefe Bäume) | ✅ **Robust** (Law of Large Numbers) |
| Feature Importance | Nicht direkt | ✅ **Variable Importance** Plot |
| Interpretierbarkeit | ✅ Vollständig | ❌ Blackbox |

### Ergebnis (Reduced)

| Metrik | Wert |
|--------|------|
| **FP (TOD)** | **0** |
| FN (harmlos) | 0 |
| Accuracy | **100,00%** |
| Specificity | 100,00% |
| AUC | 1,000 |
| OOB Error | 0,00% |

RF erreicht auf der Reduced-Variante **perfekte Klassifikation** (0 FP, 0 FN) — besser als jeder Einzelbaum. Das Ensemble aus 500 Bäumen fängt alle subtilen Muster ein.

> **Kernerkenntnis:** RF ist der **stärkste Klassifikator** (perfekte Metriken), aber eine Blackbox. Der Cost-sensitive Tree bleibt erklärbar (0 FP, 20 FN) — **Trade-off: Performance vs. Transparenz**.

---

<!-- note: Hier ist der finale Vergleich. Wichtig: Nicht nur Accuracy vergleichen, sondern vor allem FP (tödlich) und FN (harmlos). RF Reduced erreicht 0 FP, 0 FN, 100% Accuracy — die besten Metriken. Cost-sensitive Tree ebenfalls 0 FP, aber 20 FN, dafür voll interpretierbar. Die LogReg ist aus didaktischen Gründen dabei (zeigt Perfect Separation). -->

## Modellvergleich

**Reduced-Variante (19 Features, Pilzsammler-Szenario):**

| Modell | FP (TOD) | FN | Accuracy | Specificity | Interpretierbar |
| LogReg (glm) | ❌ 1262* | 0 | 0,12%* | 0,26%* | ❌ (nicht konvergiert) |
| **Tree Cost-sensitive** | **✅ 0** | 20 | 99,18% | **100%** | **✅ Voll** |
| Tree Standard | 2 | 4 | 99,75% | 99,83% | ✅ Voll |
| **RF Reduced** | **✅ 0** | **0** | **100%** | **100%** | ❌ (Blackbox) |

*\*Werte ungültig wegen Non-Convergence*

> **Kernerkenntnis:** **RF Reduced** ist nach Metriken das beste Modell (0 FP, 0 FN, 100%). Der **Cost-sensitive Tree** liefert ebenfalls 0 FP und ist **voll interpretierbar** — für die Praxis die bessere Wahl.

---

<!-- note: Das Fazit soll klar die Empfehlung aussprechen. Der Cost-sensitive Tree ist das beste Modell für dieses Szenario, weil: (1) 0 tödliche Fehler, (2) voll interpretierbar (wichtig für Präsentation), (3) robust durch cp-Tuning + 1-SE-Regel. Der Random Forest dient als "second opinion" für maximale Accuracy. Die LogReg ist kein Fehler – sie zeigt wertvolles Methodenverständnis. -->

## Fazit

### Drei Methoden, ein klares Ergebnis

| Modell | Status |
|---|---|---|
| **Logistische Regression** | ❌ Ungeeignet – Perfect Separation (Ch. 4.1) |
| **Decision Tree (Cost-sensitive)** | ✅ **Empfohlen für Praxis** – 0 FP, erklärbar |
| **Random Forest** | ✅ **Beste Metriken** – perfekte Klassifikation, aber Blackbox |

### Zwei Wege zum Ziel

| Kriterium | Cost-sensitive Tree | Random Forest |
|-----------|:------------------:|:-------------:|
| FP (TOD) | **0** | **0** |
| FN | 20 | **0** |
| Interpretierbar | **Ja** | Nein |
| Empfehlung | **Praxis (erklärbar)** | **Forschung (max. Performance)** |

### Methodische Erkenntnisse

- Nicht jedes Verfahren passt zu jedem Datensatz (LogReg ≠ Mushroom)
- **Asymmetrische Kosten** müssen ins Modell eingebaut werden (Loss Matrix)
- **Einfach + erklärbar** ist oft besser als komplex + Blackbox
- Ensemble-Methoden (RF) liefern beste Metriken, aber auf Kosten der Transparenz

---

<!-- note: Abschlussfolie – kein Fachinhalt mehr. Danke und Fragen. Je nach Zeit kann man auf die Baumregeln eingehen oder die Cost-Matrix genauer erklären. -->

# Vielen Dank!

**Fragen & Diskussion**

---

*Prüfungsstudienarbeit "Maschinelles Lernen" SS2026*
*TH Deggendorf · Prof. Hable*
*Code & Dokumentation: github.com/...*
