# Deskriptive Analyse -- Mushroom Dataset

## 1. Cramers's V -- Assoziation der Merkmale mit der Zielvariable

Cramers's V misst die Stärke des Zusammenhangs zwischen jedem Merkmal und der Zielvariable `class` (essbar/giftig). Wertebereich: 0 (kein Zusammenhang) bis 1 (perfekte Trennung).

| Rang | Merkmal | Cramers's V | Interpretation |
|---|---|---|---|
| 1 | odor (Geruch) | **0.971** | nahezu perfekte Trennung |
| 2 | spore_print_color (Sporenpulverfarbe) | **0.753** | sehr starker Zusammenhang |
| 3 | gill_color (Lamellenfarbe) | **0.681** | starker Zusammenhang |
| 4 | stalk_surface_above_ring (Stieloberfläche oberhalb Ring) | 0.588 | mäßig starker Zusammenhang |
| 5 | stalk_surface_below_ring (Stieloberfläche unterhalb Ring) | 0.575 | mäßig starker Zusammenhang |
| 6 | gill_size (Lamellengröße) | 0.540 | mäßig starker Zusammenhang |
| 7 | stalk_color_above_ring (Stielfarbe oberhalb Ring) | 0.525 | mäßig starker Zusammenhang |
| 8 | stalk_color_below_ring (Stielfarbe unterhalb Ring) | 0.515 | mäßig starker Zusammenhang |
| 9 | bruises (Druckstellen) | 0.502 | mäßig starker Zusammenhang |
| 10 | population (Wuchsform) | 0.487 | schwächerer Zusammenhang |
| 11 | habitat (Lebensraum) | 0.440 | schwächerer Zusammenhang |
| 12 | cap_shape (Hutform) | 0.246 | schwacher Zusammenhang |
| 13 | cap_color (Hutfarbe) | 0.218 | schwacher Zusammenhang |
| 14 | ring_number (Ringanzahl) | 0.215 | schwacher Zusammenhang |
| 15 | cap_surface (Hutoberfläche) | 0.197 | schwacher Zusammenhang |
| 16 | veil_color (Velumfarbe) | 0.153 | sehr schwacher Zusammenhang |
| 17 | stalk_shape (Stielform) | 0.102 | sehr schwacher Zusammenhang |

![Cramers's V aller Merkmale](../docs/plots/cramers_v.png)

---

## 2. Target-Verteilung

Die Klasse ist nahezu balanciert:

| Klasse | Anzahl | Anteil |
|---|---|---|
| edible (essbar) | 4.208 | 51,8 % |
| poisonous (giftig) | 3.916 | 48,2 % |

---

## 3. Detailanalyse der Top-8 Merkmale

![Konditionale Barplots der Top-8 Merkmale](../docs/plots/top8_conditional_barplots.png)

### 3.1 Odor (Geruch) -- Cramers's V = 0.971

Der Geruch ist mit Abstand das trennschärfste Merkmal. Mehrere Geruchsausprägungen sind **perfekte Indikatoren** für Giftigkeit:

- **Eindeutig giftig**: creosote, fishy, foul, musty, pungent, spicy -- alle zu 100 % giftig
- **Eindeutig essbar**: almond, anise -- alle zu 100 % essbar
- **Geruchslos** (none): zu 96,6 % essbar, zu 3,4 % giftig

Für die Praxis bedeutet das: Ein Pilz mit starkem, unangenehmem Geruch ist mit hoher Sicherheit giftig.

### 3.2 Spore Print Color (Sporenpulverfarbe) -- Cramers's V = 0.753

- **Eindeutig essbar**: buff, orange, purple, yellow -- zu 100 % essbar
- **Eindeutig giftig**: green (100 %), chocolate (97,1 %)
- **Gemischt**: black (88 % essbar), brown (88,6 % essbar), white (75,9 % giftig)

### 3.3 Gill Color (Lamellenfarbe) -- Cramers's V = 0.681

- **Eindeutig essbar**: orange, red -- zu 100 % essbar
- **Eindeutig giftig**: buff, green -- zu 100 % giftig
- **Gemischt**: chocolate (72,1 % giftig), gray (67 % giftig), purple (90,2 % essbar), white (79,5 % essbar)

### 3.4 Stalk Surface Above Ring (Stieloberfläche oberhalb des Rings) -- Cramers's V = 0.588

- **silky** (seidig): zu 93,9 % giftig -- starke Tendenz
- **fibrous** (faserig), **scaly** (schuppig), **smooth** (glatt): überwiegend essbar (67--74 %)

### 3.5 Stalk Surface Below Ring (Stieloberfläche unterhalb des Rings) -- Cramers's V = 0.575

- **silky** (seidig): zu 93,8 % giftig -- gleiches Muster wie oberhalb des Rings
- **fibrous**, **scaly**, **smooth**: überwiegend essbar (69--76 %)

### 3.6 Gill Size (Lamellengröße) -- Cramers's V = 0.540

- **broad** (breit): zu 69,9 % essbar
- **narrow** (schmal): zu 88,5 % giftig -- schmale Lamellen sind ein starker Giftindikator

### 3.7 Stalk Color Above Ring (Stielfarbe oberhalb des Rings) -- Cramers's V = 0.525

- **brown, buff, cinnamon, yellow**: zu 96,4--100 % giftig
- **gray, orange, red**: zu 100 % essbar
- **white**: gemischt (61,6 % essbar)

### 3.8 Stalk Color Below Ring (Stielfarbe unterhalb des Rings) -- Cramers's V = 0.515

- **buff, cinnamon, yellow**: zu 100 % giftig
- **brown**: 87,5 % giftig
- **gray, orange, red**: zu 100 % essbar
- **white**: gemischt (61,7 % essbar)

---

## 4. Auffälligkeiten

### 4.1 Odor dominiert

`odor` erreicht mit 0.971 nahezu eine perfekte Trennung. Die Merkmale `spore_print_color` (0.753) und `gill_color` (0.681) sind ebenfalls starke Prädiktoren, aber deutlich schwächer als der Geruch.

> **Hinweis zu den zwei Varianten**: Für das realistischere Pilzsammler-Szenario (Reduced-Variante) werden `odor` und `spore_print_color` entfernt. `gill_color` bleibt erhalten, da die Lamellenfarbe ein Standard-Bestimmungsmerkmal ist. Die Cramers's-V-Tabelle bezieht sich auf die Full-Variante (21 Features).

### 4.2 Oberfläche vs. Farbe des Stiels

Die Stieloberfläche (ober- und unterhalb des Rings) ist ähnlich relevant (~0.58). Die Stielfarbe (ober- und unterhalb) liegt etwas darunter (~0.52). Das deutet darauf hin, dass die **Beschaffenheit** des Stiels relevanter ist als seine Farbe.

### 4.3 Redundanz zwischen verwandten Merkmalen

- `stalk_surface_above_ring` und `stalk_surface_below_ring` sind nahezu identisch in ihrer Aussagekraft (0.588 vs. 0.575) und ihren bedingten Verteilungen.
- Gleiches gilt für `stalk_color_above_ring` und `stalk_color_below_ring` (0.525 vs. 0.515).
- Dies sind mögliche Kandidaten für Redundanz in einem Modell.

### 4.4 Konstantes Merkmal (entfernt)

`veil_type` hat nur eine einzige Ausprägung ("partial" / Teilvelum) und ist damit für die Klassifikation vollständig irrelevant. Gemäß Kapitel 3.1 der Vorlesung (Entfernen irrelevanter Daten) wurde das Merkmal daher während der Datenaufbereitung aus dem Datensatz entfernt. Die Modelle werden mit 21 statt 22 Merkmalen trainiert.

### 4.5 Schwache Merkmale

`stalk_shape` (0.102) und `veil_color` (0.153) haben praktisch keinen Zusammenhang mit der Genießbarkeit und liefern kaum Mehrwert für die Klassifikation.

### 4.6 Problem für die logistische Regression: Quasi-Complete Separation

Der Datensatz enthält mehrere Merkmale mit **perfekt trennenden Ausprägungen**:

- `odor`: 7 von 9 Ausprägungen sind 100%-Indikatoren (Cramers's V = 0.971)
- `spore_print_color`: 4 von 9 Ausprägungen sind 100%-Indikatoren (Cramers's V = 0.753)
- `gill_color`: 4 von 12 Ausprägungen sind 100%-Indikatoren (Cramers's V = 0.681)
- `stalk_color_above_ring`: 3 von 9 Ausprägungen sind 100%-Indikatoren (Cramers's V = 0.525)
- `stalk_color_below_ring`: 3 von 9 Ausprägungen sind 100%-Indikatoren (Cramers's V = 0.515)

Das bedeutet: Selbst in der Reduced-Variante (ohne `odor` + `spore_print_color`) existieren noch Merkmale mit perfekt trennenden Leveln (`gill_color`, `stalk_color_above_ring`, `stalk_color_below_ring`). Die logistische Regression (unregularisiertes `glm`) kann unter diesen Bedingungen **keinen endlichen Maximum-Likelihood-Schätzer** finden -- die Koeffizienten divergieren gegen +-/unendl. Dieses Phänomen wird in Kapitel 4.1 der Vorlesung als "Complete Separation" thematisiert und ist der Grund, warum `glm` auf diesem Datensatz nicht als Baseline-Modell eingesetzt werden kann.

Tree-basierte Verfahren (Entscheidungsbäume, Random Forest) haben dieses Problem nicht, da sie nicht alle Parameter simultan schätzen, sondern gierig partitionieren.

---

## 5. Erweiterte Analysemöglichkeiten

Die folgenden Verfahren werden in der Praxis häufig eingesetzt, um kategoriale Daten wie diesen Datensatz tiefergehend zu analysieren:

### 5.1 Multiple Correspondence Analysis (MCA)

Die MCA ist das Pendant zur PCA für nominale Daten. Sie projiziert die Ausprägungen aller Merkmale in einen niedrigdimensionalen Raum und visualisiert, welche Kategorien häufig gemeinsam auftreten. Für den Mushroom-Datensatz ließe sich damit beispielsweise zeigen, dass die Ausprägungen `odor=almond`, `gill_size=broad` und `habitat=woods` im selben Bereich des Koordinatenraums cluster -- also typisch für essbare Pilze sind.

### 5.2 Mutual Information

Während Cramers's V auf der Chi-Quadrat-Statistik basiert, misst die Transinformation (Mutual Information) den informations-theoretischen Zusammenhang zwischen Merkmal und Zielvariable. Sie erfasst auch nicht-lineare Abhängigkeiten und ist robuster bei unbalancierten Randverteilungen. Für Merkmale wie `odor` wäre der Wert nahe 1 Bit (perfekte Vorhersage), für `stalk_shape` nahe 0 Bit.

### 5.3 Assoziationsregeln (Apriori-Algorithmus)

Mit dem Apriori-Algorithmus ließen sich Regeln der Form `{odor=none, gill_size=broad} -> {class=edible}` extrahieren. Das wäre besonders praxisrelevant, da es konkrete, kombinierte Merkmalsmuster identifiziert, die eine sichere Klassifikation erlauben. So könnte man etwa prüfen, ob bestimmte Ausprägungskombinationen eine 100 % treffsichere Unterscheidung erlauben -- ohne Modell.

### 5.4 Adjusted Chi-Quadrat-Residuen

Die adjustierten Residuen einer Kontingenztabelle zeigen je Feature-Ausprägung, ob die beobachtete Häufigkeit signifikant von der unter Unabhängigkeit erwarteten abweicht. Positive Residuen bedeuten eine überdurchschnittliche Assoziation mit `edible`, negative mit `poisonous`. Dies erlaubt eine feinere Analyse als der globale Cramers's V -- insbesondere für Merkmale mit vielen Ausprägungen wie `gill_color`.

### 5.5 Feature-Interaktionen

Einzelne schwache Merkmale können in Kombination starke Prädiktoren sein. Beispielsweise haben `veil_color` und `stalk_shape` einzeln kaum Vorhersagekraft (Cramers's V < 0,16), aber ihre gemeinsame Betrachtung könnte durchaus Muster offenbaren. Eine Interaktionsanalyse (z. B. mit log-linearen Modellen oder Entscheidungsbäumen) kann solche verborgene Zusammenhänge aufdecken.

### 5.6 Mosaic-Plots

Alternativ zu den konditionalen Barplots visualisieren Mosaic-Plots Kontingenztabellen flächenproportional. Jede Zelle wird als Rechteck dargestellt, dessen Fläche der Häufigkeit entspricht. Die Färbung zeigt die Abweichung von der erwarteten Verteilung. Für den Mushroom-Datensatz könnte ein einziger Mosaic-Plot über alle 22 Merkmale hinweg auf einen Blick zeigen, welche Ausprägungen stark von der Gleichverteilung abweichen.

### 5.7 Heatmap der bedingten Wahrscheinlichkeiten

Eine farbcodierte Matrix mit den Features als Zeilen und ihren Ausprägungen als Spalten, eingefärbt nach dem Anteil giftiger Pilze pro Kategorie. Rot = überwiegend giftig, Grün = überwiegend essbar. Ein solcher Plot komprimiert die gesamte deskriptive Analyse in eine einzige Abbildung und eignet sich ideal als Übersichtsfolie für die Präsentation.
