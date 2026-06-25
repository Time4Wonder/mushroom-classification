# Decision Tree — Modellanalyse

## 1. Funktionsweise (Ch. 4.1)

Ein Entscheidungsbaum partitioniert den Merkmalsraum rekursiv. An jedem Knoten wird **das Merkmal** ausgewählt, das die Daten am "reinesten" in die beiden Klassen teilt (Gini-Index als Splittkriterium). Der Baum wächst von der Wurzel zu den Blättern, bis ein Abbruchkriterium ($cp$) erreicht ist.

**Vorteile für diesen Datensatz:**
- Nominale Merkmale werden nativ verarbeitet (keine Dummy-Kodierung nötig)
- Keine Koeffizientenschätzung → kein Perfect-Seperation-Problem
- Ergebnis ist eine *Regel*: "Wenn Lamelle orange → essbar" — intuitiv nachvollziehbar

## 2. cp-Tuning mit 10-fold CV (Ch. 6.3)

Der Parameter $cp$ (Complexity Parameter) steuert die Größe des Baums:
- $cp = 0$: maximaler Baum (überangepasst)
- $cp = 1$: nur der Wurzelknoten (unterangepasst)

Die optimale Größe wird durch **10-fache Kreuzvalidierung** auf dem Trainingsdatensatz bestimmt. `rpart` führt diese CV **eingebaut** durch (`rpart.control(xval = 10)`).

### 2.1 cp-Tabelle

```
   CP       nsplit   rel error   xerror    xstd
   0.60124   0      1.00000     1.00000   0.01375
   0.12003   1      0.39876     0.39876   0.01084
   0.08756   2      0.27873     0.27873   0.00938
   0.04524   3      0.19117     0.19409   0.00801
   0.02335   4      0.14593     0.14885   0.00710
   0.02153   5      0.12258     0.14082   0.00692
   0.01751   6      0.10106     0.12039   0.00643
   0.01131   7      0.08355     0.09923   0.00587
   0.01076   8      0.07224     0.07917   0.00527
   0.00657  10      0.05071     0.05472   0.00441
   0.00518  11      0.04414     0.04925   0.00419
   0.00365  16      0.01824     0.02444   0.00297
   0.00328  17      0.01459     0.01423   0.00227
   0.00109  19      0.00803     0.00547   0.00141
   0.00100  20      0.00693     0.00693   0.00159
```

- **rel error**: Fehler auf Trainingsdaten (fällt monoton mit mehr Splits)
- **xerror**: CV-Fehler (10-fold) — das relevante Maß
- **xstd**: Standardabweichung des CV-Fehlers

### 2.2 1-SE-Regel

Die 1-SE-Regel (Ch. 6.3) wählt nicht den Baum mit dem minimalen CV-Fehler, sondern den **einfachsten Baum**, dessen CV-Fehler innerhalb von einer Standardabweichung des Minimums liegt:

| Größe | Wert |
|---|---|
| Minimaler xerror | 0,00547 (bei 19 Splits, cp = 0,00109) |
| xstd | 0,00141 |
| Schwelle (min + 1 SE) | 0,00688 |
| Gewählter cp (1-SE) | **0,00109** (identisch mit Minimum) |

In diesem Fall fällt die Schwelle genau auf das Minimum selbst — der nächstkleinere Baum (1 Split weniger) überschreitet bereits die Schwelle. Die 1-SE-Regel bestätigt damit das Minimum.

## 3. Finale Baumstruktur (Standard Tree 1:1)

Der Standard-Baum (keine Kosten) hat **38 Splits** und nutzt **11 von 19 Merkmalen**:

| Split-Ebene | Merkmal | Bedeutung |
|---|---|---|
| Wurzel (1) | `gill_color` | Lamellenfarbe — stärkster Prädiktor in der Reduced-Variante |
| 2 | `ring_type` | Ring-Typ |
| 3 | `gill_size` | Lamellengröße |
| 4 | `habitat` | Lebensraum |
| 5 | `cap_color` | Hutfarbe |
| 6 | `cap_surface` / `stalk_shape` | Hutoberfläche / Stielform |
| 7 | `bruises` / `population` | Druckstellen / Wuchsform |
| ... | ... | |

**Interessante Regeln aus dem Baum:**

- `gill_color = black,brown,orange,pink,purple,red,white,yellow` & `ring_type = large,none` → **immer giftig** (Knoten 5, 0% edible)
- `gill_color = buff,chocolate,gray,green` & `population = several,solitary` → **99,5% giftig** (Knoten 15)
- `gill_color = black,...` & `gill_size = broad` & `habitat != urban` & `cap_surface = fibrous,scaly` → **99,6% essbar** (Knoten 64)

## 4. Cost-sensitive Learning: Loss Matrix

### 4.1 Motivation

Bisher behandelt der Standard-Baum jeden Fehler gleich (1:1). Tatsächlich sind die Kosten extrem asymmetrisch:

- **FP (giftig → essbar)** = **tödlich** → maximale Vermeidung
- **FN (essbar → giftig)** = harmlos (Pilz wird nicht gegessen)

### 4.2 Loss Matrix in rpart

`rpart` unterstützt Cost-sensitive Learning über den `parms = list(loss = ...)`-Parameter. Die Loss-Matrix definiert die Kosten pro Fehlertyp:

```
           vorhergesagt edible   vorhergesagt poisonous
edible          0 (korrekt)          1 (FP = harmlos)
poisonous      10 (FN = TOD)         0 (korrekt)
```

Die Werte bedeuten: Ein giftiger Pilz, der als essbar eingestuft wird (FP), kostet **10-mal mehr** als ein essbarer, der als giftig eingestuft wird (FN). Der Baum wächst dann so, dass diese teuren Fehler bevorzugt vermieden werden — auch auf Kosten von mehr harmlosen Fehlern.

### 4.3 Effekt auf die Baumstruktur

Der Cost-sensitive Baum wird **größer** (68 Splits statt 38) und verwendet mehr Merkmale (15 statt 11). Die Wurzel splittet nun nicht mehr nach `gill_color`, sondern nach `stalk_color_above_ring` — der Baum sucht zuerst nach Merkmalen, die giftige Pilze **sicher erkennen**.

### 4.4 Baumvisualisierung

![Cost-sensitive Decision Tree](plots/tree_plot.png)

Der Plot zeigt den Cost-sensitive Baum mit der Loss-Matrix (FN 10x). Grüne Knoten = mehrheitlich essbar, rote Knoten = mehrheitlich giftig. Der erste Split erfolgt auf `stalk_color_above_ring` — alle Pilze mit grauen, orangen oder roten Stielfarben werden sofort als essbar eingestuft (reiner Blattknoten). Der Baum ist mit 68 Splits deutlich komplexer als der Standard-Baum.

## 5. Modellergebnisse im Vergleich

### 5.1 Confusion Matrices

**Standard Tree (1:1):**
| | Tatsächlich edible | Tatsächlich poisonous |
|---|---|---|
| **Vorhergesagt edible** | 1258 (TP) | **2 (FP = TOD)** |
| **Vorhergesagt poisonous** | 4 (FN) | 1173 (TN) |

**Cost-sensitive Tree (FN 10x):**
| | Tatsächlich edible | Tatsächlich poisonous |
|---|---|---|
| **Vorhergesagt edible** | 1242 (TP) | **0 (FP = TOD)** |
| **Vorhergesagt poisonous** | 20 (FN) | 1175 (TN) |

### 5.2 Metriken im Vergleich

| Metrik | Standard (1:1) | Cost-sensitive (10x) | Bewertung |
|---|---|---|---|
| **FP (giftig → essbar)** | **2** | **0** | ✅ Cost gewinnt — kein tödlicher Fehler |
| FN (essbar → giftig) | 4 | 20 | Standard gewinnt — aber harmlos |
| Accuracy | 99,75% | 99,18% | Standard gewinnt — aber zweitrangig |
| Sensitivity (edible correct) | 99,68% | 98,42% | Standard gewinnt |
| Specificity (poisonous correct) | 99,83% | **100,00%** | Cost gewinnt — alle giftigen erkannt |
| Balanced Accuracy | 99,76% | 99,21% | |

### 5.3 Interpretation

Der **Standard-Baum** macht 2 tödliche Fehler (giftig → essbar). Der **Cost-sensitive Baum** macht **0 tödliche Fehler** — alle 1175 giftigen Pilze werden korrekt erkannt. Der Preis: 16 mehr harmlose Fehlalarme (essbare werden als giftig eingestuft, insgesamt 20 statt 4).

Für das Anwendungsszenario "Pilzbestimmung" ist der Cost-sensitive Baum **die bessere Wahl** — kein Pilzvergiftungsrisiko, selbst wenn ein paar essbare Pilze unnötig aussortiert werden.

## 6. Vergleich mit Logistischer Regression

| Aspekt | glm (LogReg) | rpart Standard | rpart Cost-sensitive |
|---|---|---|---|
| Konvergenz | **Nein** — Perfect Separation | **Ja** | **Ja** |
| FP (giftig → essbar = TOD) | 1262 (ungültig) | **2** | **0** |
| Accuracy | 0,0012 (ungültig) | 99,75% | 99,18% |
| Interpretation | Koeffizienten nicht identifizierbar | Klare Wenn-Dann-Regeln | Klare Wenn-Dann-Regeln |
| Ergebnis | **Nicht geeignet** | **Sehr gut** | **Optimal (0 FP)** |

## 7. Fazit

Der Entscheidungsbaum ist ein **exzellentes Modell** für dieses Projekt:

| Variante | FP (tödlich) | FN (harmlos) | Accuracy | Einsatz |
|---|---|---|---|---|
| Standard (1:1) | 2 | 4 | 99,75% | Baseline |
| **Cost-sensitive (10x)** | **0** | 20 | 99,18% | **Empfohlen für Praxis** |

Der Cost-sensitive Baum ist das **empfohlene Modell**: Kein Risiko für Pilzvergiftung, voll interpretierbar, und die 20 harmlosen Fehlalarme sind im Anwendungskontext akzeptabel. Der Standard-Baum dient als Benchmark für das dritte Modell (Random Forest).
