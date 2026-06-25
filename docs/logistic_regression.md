# Logistische Regression -- Modellanalyse

## 1. Theoretischer Hintergrund (Ch. 4.1)

Die logistische Regression modelliert die Wahrscheinlichkeit $P(Y = 1 \mid X)$ (hier: $Y = \text{edible}$) über die logit-Funktion:

$$
\log\left(\frac{P(Y=1 \mid X)}{1 - P(Y=1 \mid X)}\right) = \beta_0 + \beta_1 X_1 + \dots + \beta_p X_p
$$

Die Koeffizienten werden **per Maximum Likelihood** geschätzt -- es wird der Parametervektor $\beta$ gesucht, der die beobachteten Daten unter dem Modell am plausibelsten macht.

Für nominale Merkmale mit $k$ Ausprägungen werden $k-1$ Dummy-Variablen erzeugt. Bei 19--21 Merkmalen (viele mit 6--12 Ausprägungen) entstehen schnell 80+ Dummy-Variablen.

## 2. Complete Separation -- ein bekanntes Problem

**Definition:** Complete Separation liegt vor, wenn eine Linearkombination der Prädiktoren die beiden Klassen perfekt trennt -- d.h. alle Beobachtungen mit $Y=1$ haben einen positiven Vorhersagewert, alle mit $Y=0$ einen negativen.

**Konsequenz:** Die Likelihood-Funktion hat ihr Maximum im Unendlichen. Die IRLS-Optimierung treibt die betroffenen Koeffizienten gegen $\pm\infty$, die Standardfehler werden absurd groß, und der Algorithmus konvergiert nicht (Warning: `glm.fit: algorithm did not converge`).

### 2.1 Full-Variante (21 Features)

Mit `odor` (Cramers's V = 0.971) ist die Separation nahezu perfekt:

- 7 von 9 Geruchsausprägungen sind **100%ige Indikatoren**
- Nur `none` (96,6 % essbar / 3,4 % giftig) hat minimale Überlappung

**Ergebnis:** `glm` konvergiert nicht. Residual Deviance = praktisch 0. Keine verwertbaren Koeffizienten.

### 2.2 Reduced-Variante (19 Features, ohne `odor` + `spore_print_color`)

Auch nach Entfernen der beiden stärksten Prädiktoren persistiert das Problem:

- `gill_color`: `orange`/`red` -> 100 % essbar, `buff`/`green` -> 100 % giftig
- `stalk_color_above_ring`: `gray`/`orange`/`red` -> 100 % essbar, `buff`/`cinnamon` -> 100 % giftig
- `stalk_color_below_ring`: `gray`/`orange`/`red` -> 100 % essbar, `cinnamon` -> 100 % giftig

**Ergebnis:** `glm` konvergiert erneut nicht. Residual Deviance = $6.5 \times 10^{-8}$ (degenerierter Fit), 6 Koeffizienten wegen Singularitäten nicht definiert.

## 3. Modellergebnisse

### 3.1 Confusion Matrix (Reduced-Variante -- ungültig wegen Non-Convergence)

| | Tatsächlich edible | Tatsächlich poisonous |
|---|---|---|
| **Vorhergesagt edible** | 0 | 1172 |
| **Vorhergesagt poisonous** | 1262 | 3 |

### 3.2 Metriken (ungültig)

| Metrik | Wert | Anmerkung |
|---|---|---|
| Accuracy | 0,0012 | Modell klassifiziert fast alle als "poisonous" |
| Sensitivity | 0,0000 | Kein einziger essbarer Pilz erkannt |
| Specificity | 0,0026 | Nur 3 von 1175 giftigen korrekt |
| Balanced Accuracy | 0,0013 | |

**Interpretation:** Die Metriken sind **nicht vertrauenswürdig**. Der degenerierte Fit produziert sinnlose Vorhersagen.

### 3.3 Asymmetrische Kosten -- der entscheidende Aspekt

Im Anwendungsszenario "Pilzbestimmung" sind die Kosten der Fehlklassifikation **extrem asymmetrisch**:

| Fehler | Bedeutung | Konsequenz |
|---|---|---|
| **FN** (False Negative) | Giftiger Pilz als essbar eingestuft | **Tödlich** -- muss unbedingt vermieden werden |
| **FP** (False Positive) | Essbarer Pilz als giftig eingestuft | Pilz wird nicht gegessen -- ärgerlich, aber harmlos |

Die Confusion Matrix zeigt **FN = 1262**: Das Modell stuft 1262 giftige Pilze als essbar ein. Wäre das Modell ernstzunehmen, wäre dies ein katastrophales Ergebnis -- jeder dieser Fehler könnte tödlich enden.

Tatsächlich sind die Metriken aufgrund der Non-Convergence nicht interpretierbar. Die Bewertung wird daher auf die erfolgreichen Tree-Modelle (rpart, RF) verlagert, wo **die FN-Rate als primäres Entscheidungskriterium** Priorität vor der Accuracy hat.

## 4. Warum versagt glm auf diesem Datensatz?

### 4.1 Deterministische Merkmals-Giftigkeit-Beziehungen

Der UCI Mushroom Datensatz wurde **nicht** für statistische Modelle konzipiert, sondern als Sammlung deterministischer Bestimmungsregeln. Viele Merkmale haben Ausprägungen, die *biologisch zwingend* mit Giftigkeit oder Essbarkeit einhergehen. Die logistische Regression als probabilistisches Modell ist dafür das falsche Werkzeug.

### 4.2 Simultane Schätzung als Achillesferse

glm schätzt **alle Koeffizienten gleichzeitig**. Ein einziges Merkmal mit einer perfekt trennenden Ausprägung reicht aus, um die gesamte Optimierung zum Entgleisen zu bringen -- auch wenn die übrigen 18 Merkmale harmlos wären.

### 4.3 Vergleich: Warum Bäume funktionieren

| Aspekt | glm (LogReg) | rpart / Random Forest |
|---|---|---|
| Schätzung | Simultane ML-Schätzung | Gierige Split-Suche |
| Perfekte Trennung | Bricht die Optimierung | Erzeugt sofort einen Blattknoten |
| Koeffizienten | Nicht identifizierbar (/NA) | Nicht nötig |
| Interpretation | Log-Odds-Ratios | Split-Struktur |
| Geeignet für | Überlappende Verteilungen | Deterministische Regeln |

## 5. Mögliche Lösungsansätze

1. **Regularisierte LogReg (Firth's Bias-Reduktion)**: `logistf`- oder `brglm2`-Paket -- fügt einen Strafterm hinzu, der die Divergenz verhindert
2. **LASSO (Ch. 9.3)**: Schrumpft Koeffizienten automatisch auf 0 -- selektiert die relevantesten Features
3. **Kein glm**: Stattdessen Tree-basierte Verfahren als primäre Methode (dieses Projekt)
4. **Feature-Reduktion**: Manuelle Selektion auf nur Merkmale ohne perfekte Level -- führt aber zu Informationsverlust und Data Leakage bei Selektion auf dem gesamten Datensatz

## 6. Fazit

Die logistische Regression (unregularisiertes `glm`) ist **für diesen Datensatz nicht geeignet**. Der Grund liegt in der Struktur der Daten (deterministische Merkmals-Giftigkeit-Beziehungen) und nicht in einem Implementierungsfehler.

Die 1262 False Negatives (giftig -> essbar) in der Confusion Matrix wären im Anwendungskontext tödlich. Dass diese Metrik hier aufgrund der Non-Convergence nicht verwertbar ist, entbindet nicht davon, sie bei den erfolgreichen Modellen (Tree, RF) als primäres Entscheidungskriterium zu nutzen.

Für die Prüfungsstudienarbeit bedeutet das:
- `glm` wird als **negatives Beispiel** dokumentiert -- "Logistische Regression an ihre Grenzen gebracht"
- Die Diskussion zeigt Methodenverständnis: *Warum* funktioniert ein Verfahren und *wann* nicht?
- Die beiden erfolgreichen Modelle werden Decision Tree (rpart) und Random Forest sein

**Lehrbuchbezug:** Das Problem wird in Kapitel 4.1 der Vorlesung angesprochen: *"Bei perfekter Trennung existiert der ML-Schätzer nicht."* Genau dieser Fall tritt hier ein.
