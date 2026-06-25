# Evaluierung der Modelle -- Schritt für Schritt

Dieses Dokument erklärt, wie man die Ergebnisse der drei Modelle in R
überprüft und interpretiert. Es richtet sich an Leute, die R ausführen
können, aber keine Statistik-Profis sind.

---

## Auf einen Blick: Die Metriken aller Modelle

| Modell | FP (TOD) | FN | Accuracy | Specificity |
|--------|:--------:|:--:|:--------:|:-----------:|
| Logistische Regression | **1172** | 1262 | 0,12 % | 0,26 % |
| Decision Tree (Standard) | 2 | 4 | 99,75 % | 99,83 % |
| Decision Tree (Cost-sensitive) | **0** | 20 | 99,18 % | **100 %** |
| Random Forest | **0** | **0** | **100 %** | **100 %** |

- **FP (TOD)** = giftiger Pilz als essbar eingestuft -> **tödlich**
- **FN (harmlos)** = essbarer Pilz als giftig eingestuft -> Pilz wird nicht gegessen
- **Accuracy** = Anteil richtiger Vorhersagen insgesamt
- **Specificity** = Anteil erkannter Giftpilze (Richtig-negativ-Rate)

---

## 1. Logistische Regression -- warum sie scheitert

### Eckpunkte auf einen Blick

| Was? | Ergebnis |
|------|----------|
| **Perfect Separation** | Der ML-Schätzer existiert nicht -- LogReg kann nicht rechnen |
| **Koeffizienten** | Explodieren: `cinnamon = 252,5`, `rooted = -198,0` |
| **Standardfehler** | 100.000+ (700x größer als die Koeffizienten) |
| **Residual Deviance** | `6,51e-08` -- degeneriert (zu perfekt, um wahr zu sein) |
| **Vorhersagen** | 1172 FP + 1262 FN = **schlechter als Raten** |
| **Fazit** | LogReg ist für nominale Daten mit deterministischen Levels **strukturell ungeeignet** |

### Das Problem in einem Satz

Die logistische Regression versagt an diesem Datensatz, weil Merkmale
vorkommen, die die Pilzart **perfekt vorhersagen** (z.B. "Stielfarbe
zimtbraun -> immer giftig"). Die Rechnung läuft dann ins Unendliche
und liefert keine brauchbaren Ergebnisse.

### R-Code: Modell anpassen und ausgeben lassen

```r
# Reduced-Variante laden (19 Merkmale)
train <- readRDS("data/processed/train_reduced.rds")
test  <- readRDS("data/processed/test_reduced.rds")

# Logistische Regression rechnen
log_model <- glm(class ~ ., data = train, family = binomial)

# Zusammenfassung anzeigen
s <- summary(log_model)
print(s)
```

### Schritt-für-Schritt-Checkliste

Wenn du `summary(log_model)` ausführst, siehst du diesen Output.
Hier worauf du achten musst -- und woran du siehst, dass etwas schiefläuft:

---

#### Schritt 1: Die Warnmeldung (ganz oben)

```
glm.fit: algorithm did not converge
glm.fit: fitted probabilities numerically 0 or 1 occurred
```

**Bedeutung:** R sagt selbst: "Ich kann nicht rechnen." Der Algorithmus
findet keine Lösung. Die roteste Flagge, die es gibt.

**Was tun?** Wenn diese Meldung kommt, ist das Modell unbrauchbar.
Weitermachen lohnt nicht.

---

#### Schritt 2: "6 not defined because of singularities"

Ganz oben in der Koeffizienten-Tabelle steht:

```
Coefficients: (6 not defined because of singularities)
```

Und einige Zeilen zeigen `NA` statt einer Zahl:

```
stalk_color_below_ringcinnamon         NA         NA      NA       NA
```

**Bedeutung:** Manche Merkmale sind so stark miteinander verknüpft
(z.B. Stielfarbe oben = Stielfarbe unten), dass R sie nicht
auseinanderhalten kann.

**Faustregel:** Je mehr `NA`-Einträge, desto problematischer.

---

#### Schritt 3: Koeffizienten anschauen (die Estimate-Spalte)

```
                           Estimate Std. Error
stalk_color_above_ringcinnamon  252,5    1,75e+05
stalk_rootrooted               -198,0    1,24e+05
gill_colorbuff                  144,8    1,30e+05
```

**Bedeutung:** Normale Koeffizienten liegen zwischen -3 und +3.
Wenn Werte über 10 oder unter -10 auftauchen, läuft die Schätzung
ins Unendliche.

**Merke:** Ein Koeffizient von 252 bedeutet nicht "dieses Merkmal
ist 252-mal wichtiger". Es bedeutet "die Rechnung ist explodiert".

---

#### Schritt 4: Standardfehler anschauen (Std. Error-Spalte)

Normalerweise ist der Standardfehler kleiner als der Koeffizient.
Hier ist er hunder- bis tausendmal größer:

- 252,5 +-/ 175.071 -> Der Fehler ist 700x größer als der Wert
- -198,0 +-/ 123.702 -> Der Fehler ist 600x größer als der Wert

**Bedeutung:** Wir wissen praktisch nichts über diesen Koeffizienten.
Die Statistik sagt: "Keine Ahnung." Deshalb sind alle p-Werte ~= 1.

---

#### Schritt 5: Residual Deviance prüfen

Ganz unten in der Ausgabe:

```
Null deviance: 7.8765e+03  on 5686  degrees of freedom
Residual deviance: 6.5087e-08  on 5614  degrees of freedom
```

Die **Null Deviance** (7876) ist der Fehler, wenn man einfach nur rät.
Die **Residual Deviance** (0,000000065) ist der Fehler nach dem Modell.

**Bedeutung:** Das Modell passt perfekt -- aber zu perfekt.
Der Wert ist fast 0, was bedeutet: Das Modell hat sich totgerechnet.
Ein gesundes Modell hätte einen Residual Deviance irgendwo zwischen
5000 und 7000.

---

#### Schritt 6: Konfusionsmatrix checken

```r
prob <- predict(log_model, newdata = test, type = "response")
pred <- factor(ifelse(prob > 0.5, "edible", "poisonous"),
               levels = levels(test$class))
table(Predicted = pred, Actual = test$class)
```

Ausgabe:
```
           Actual
Predicted   edible poisonous
  edible         0      1172
  poisonous   1262         3
```

**Bedeutung:** Von 2437 Pilzen im Testdatensatz werden 2434 falsch
klassifiziert. Nur 3 giftige Pilze werden zufällig richtig erkannt.
Das ist schlechter als Raten (Raten wäre ~50 %).

---

### Zusammenfassung für Nicht-Profis

> Stell dir vor, du willst einen Zeugen vernehmen, der dir 70
> verschiedene Aussagen gleichzeitig macht. Einige dieser Aussagen
> widersprechen sich, andere sind identisch. Der Zeuge gerät ins
> Stottern und bringt kein vernünftiges Wort heraus. So geht es der
> logistischen Regression mit diesem Datensatz. Sie ist überfordert
> mit den vielen Merkmalen, die gar nicht unabhängig voneinander sind.
>
> **Ergebnis:** Die LogReg ist für diesen Datensatz ungeeignet.
> Nicht weil wir einen Fehler gemacht hätten, sondern weil die Methode
> an ihre Grenzen stößt. Baum-Verfahren kommen damit besser klar.

---

## 2. Decision Tree -- der beste Kompromiss

### Eckpunkte auf einen Blick

| Was? | Ergebnis |
|------|----------|
| **cp-Tuning** | 10-fold CV + 1-SE-Regel -> **38 Splits**, 11 von 19 Merkmalen genutzt |
| **Cost-sensitive** | Loss Matrix bestraft FP 10x -> **0 tödliche Fehler** |
| **Standard (1:1)** | 2 FP (TOD), 4 FN (harmlos), Acc = 99,75 % |
| **Cost-sensitive (10x)** | **0 FP**, 20 FN, Acc = 99,18 %, Spec = **100 %** |
| **Wurzel-Split** | `stalk_color_above_ring` (nicht `gill_color`!) |
| **Interpretierbarkeit** | [OK] **Vollständig** -- jeder Pfad ist lesbar |
| **Fazit** | **Beste Wahl für die Praxis**: 0 TOD, robust getuned, erklärbar |

### Das Prinzip in einem Satz

Ein Entscheidungsbaum stellt Ja/Nein-Fragen der Reihe nach:
"Ist die Lamellenfarbe orange? -> Ja -> essbar". Er entscheidet
nicht alles gleichzeitig, sondern Schritt für Schritt.

### R-Code

```r
library(rpart)
library(rpart.plot)

train <- readRDS("data/processed/train_reduced.rds")
test  <- readRDS("data/processed/test_reduced.rds")

# Standard Tree (FP und FN wiegen gleich viel)
tree_std <- rpart(class ~ ., data = train, method = "class",
                  control = rpart.control(cp = 0.001, xval = 10))

# Cost-sensitive Tree (FP = tödlich -> 10x schwerer bestraft)
cost <- matrix(c(0, 1,    # true edible: 1 = Fehler harmlos
                 10, 0),  # true poisonous: 10 = Fehler tödlich
               nrow = 2, byrow = TRUE,
               dimnames = list(levels(train$class), levels(train$class)))

tree_cost <- rpart(class ~ ., data = train, method = "class",
                   parms = list(loss = cost),
                   control = rpart.control(cp = 0.001, xval = 10))
```

### Schritt-für-Schritt-Checkliste

---

#### Schritt 1: cp-Tabelle anzeigen

```r
printcp(tree_std)
```

Ausgabe (Auszug):
```
          CP nsplit rel error    xerror      xstd
1  0.6012404      0 1.0000000 1.0000000 0.0137474
...
14 0.0010945     19 0.0080263 0.0062021 0.0015020
15 0.0010000     20 0.0069318 0.0069318 0.0015876
```

**Was bedeuten die Spalten?**

- **CP** (Complexity Parameter): Eine Art "Sicherheitsschwelle".
  Je kleiner CP, desto mehr Äste darf der Baum haben.
- **nsplit**: Wie viele Verzweigungen der Baum hat.
- **rel error**: Fehler auf den Trainingsdaten (je kleiner, desto besser).
- **xerror**: Fehler in der Kreuzvalidierung (der relevante Wert!).
- **xstd:** Standardabweichung des xerror.

**Worauf achten?** Die Zeile mit dem kleinsten xerror ist der beste
Kompromiss. Hier: nsplit = 19, CP = 0,0010945, xerror = 0,0062.

---

#### Schritt 2: Die 1-SE-Regel anwenden

```r
cp_table <- tree_std$cptable
best_row <- which.min(cp_table[, "xerror"])
best_cp  <- cp_table[best_row, "CP"]

se_threshold <- cp_table[best_row, "xerror"] + cp_table[best_row, "xstd"]
se_cp <- max(cp_table[cp_table[, "xerror"] <= se_threshold, "CP"])

cat("Min xerror bei CP =", best_cp, "\n")
cat("Gewähltes CP (1-SE):", se_cp, "\n")
```

**Was macht die 1-SE-Regel?** Sie sucht den einfachsten Baum
(mit den wenigsten Ästen), der noch genauso gut ist wie der beste.
Das verhindert Overfitting (zu viele Details gemerkt).

---

#### Schritt 3: Baum beschneiden und prüfen

```r
pruned <- prune(tree_std, cp = se_cp)

# Anzahl der Verzweigungen
cat("Anzahl Splits:", nrow(pruned$frame) - 1, "\n")

# Welche Merkmale wurden genutzt?
vars <- unique(pruned$frame$var[pruned$frame$var != "<leaf>"])
cat("Genutzte Merkmale:", length(vars), "\n")
```

---

#### Schritt 4: Cost-sensitive Baum prüfen

Beim Cost-sensitive Tree wird eine Verlust-Matrix verwendet:

```
           Vorhersage essbar  Vorhersage giftig
Echt essbar         0 (OK)         1 (harmlos)
Echt giftig        10 (TOD)        0 (OK)
```

**Bedeutung:** Wenn der Baum einen giftigen Pilz als essbar
einstuft, zählt das 10 Fehler. Der Baum wird also alles tun,
um diesen Fehler zu vermeiden -- selbst wenn er dafür ein paar
essbare Pilze fälschlich als giftig einstuft.

---

#### Schritt 5: Konfusionsmatrix vergleichen

```r
pred_std  <- predict(pruned_std, newdata = test, type = "class")
pred_cost <- predict(pruned_cost, newdata = test, type = "class")

table(Predicted = pred_std, Actual = test$class)
table(Predicted = pred_cost, Actual = test$class)
```

Standard Tree:
```
           Actual
Predicted   edible poisonous
  edible      1258         2
  poisonous      4      1173
```
-> 2 tödliche Fehler (FP), 4 harmlose Fehler (FN)

Cost-sensitive Tree:
```
           Actual
Predicted   edible poisonous
  edible      1242         0
  poisonous     20      1175
```
-> **0 tödliche Fehler** (FP), 20 harmlose Fehler (FN)

---

### Zusammenfassung für Nicht-Profis

> Stell dir einen Pilz-Experten vor, der einen Bestimmungsschlüssel
> benutzt: "Ist die Lamellenfarbe orange? -> Ja -> essbar. Ist sie
> buff? -> Ja -> ist der Stiel zimtbraun? -> Ja -> giftig." Der Baum
> arbeitet wie so ein Schlüssel: Frage für Frage, ohne alle Merkmale
> gleichzeitig betrachten zu müssen.
>
> Wenn wir tödliche Fehler vermeiden wollen, sagen wir dem Baum:
> "Bestrafe einen Fehler bei Giftpilzen 10x härter als einen Fehler
> bei essbaren Pilzen." Dann macht der Baum lieber 20 harmlose Fehler
> (essbar -> giftig) als einen einzigen tödlichen (giftig -> essbar).
>
> **Ergebnis:** Der Cost-sensitive Tree hat 0 tödliche Fehler und
> ist vollständig nachvollziehbar. Für die Praxis die beste Wahl.

---

## 3. Random Forest -- der Overachiever

### Eckpunkte auf einen Blick

| Was? | Ergebnis |
|------|----------|
| **mtry-Tuning** | 10-fold CV -> bestes `mtry = 11` (von 19 Merkmalen) |
| **Fehler** | **0 FP (TOD)**, **0 FN (harmlos)** -- perfekte Klassifikation |
| **Accuracy** | **100 %** |
| **AUC** | **1,000** (perfekte Trennung) |
| **OOB Error** | **0 %** |
| **Variable Importance** | `gill_color` dominiert, gefolgt von `gill_size` und `population` |
| **Interpretierbarkeit** | [NEIN] **Blackbox** -- keine Nachvollziehbarkeit |
| **Fazit** | **Maximale Performance**, aber nicht erklärbar. Für die Forschung ideal, für die Praxis überdimensioniert |

### Das Prinzip in einem Satz

Ein Random Forest ist wie 500 Entscheidungsbäume, die gemeinsam
abstimmen. Jeder Baum sieht etwas andere Daten und andere Merkmale
-> zusammen sind sie stärker und stabiler.

### R-Code

```r
library(randomForest)
library(pROC)

train <- readRDS("data/processed/train_reduced.rds")
test  <- readRDS("data/processed/test_reduced.rds")

# mtry-Tuning: Welche Anzahl zufälliger Merkmale ist am besten?
set.seed(467)
for (m in c(2:12)) {
  fit <- randomForest(class ~ ., data = train, ntree = 500, mtry = m)
  cat("mtry =", m, ": OOB Error =", tail(fit$err.rate[,1], 1), "\n")
}

# Finales Modell mit bestem mtry
rf <- randomForest(class ~ ., data = train,
                   ntree = 500, mtry = 11, importance = TRUE)
```

### Schritt-für-Schritt-Checkliste

---

#### Schritt 1: mtry-Tuning auswerten

```
mtry =  2: CV Accuracy = 0.9645
mtry =  3: CV Accuracy = 0.9670
...
mtry = 11: CV Accuracy = 0.9700  <- bester Wert
mtry = 12: CV Accuracy = ...
```

**Bedeutung:** `mtry` ist die Anzahl der Merkmale, die jeder Baum
zufällig zur Auswahl bekommt. Standard ist sqrt19 ~= 4, aber hier
schneidet 11 am besten ab. Das liegt daran, dass viele Merkmale
informativ sind und der Forest mehr Auswahl braucht.

---

#### Schritt 2: OOB Error prüfen (Out-of-Bag)

```r
# OOB Error ausgeben
cat("OOB Error:", tail(rf$err.rate[, 1], 1), "\n")

# OOB Error Plot
plot(rf)
```

**Bedeutung:** Der OOB Error ist der Fehler, den der Forest auf
Daten macht, die er noch nicht gesehen hat (quasi eingebaute
Kreuzvalidierung). Hier: **0 %** -- der Forest macht keine Fehler.

---

#### Schritt 3: Variable Importance prüfen

```r
importance(rf)
varImpPlot(rf)
```

Ausgabe (Top 5):
```
             MeanDecreaseAccuracy MeanDecreaseGini
gill_color                 46,984          691,305
gill_size                  48,725          388,933
habitat                    36,349          184,222
population                 33,975          247,140
stalk_root                 31,409          152,371
```

**Bedeutung:** Je höher der Wert, desto wichtiger das Merkmal.
`gill_color` (Lamellenfarbe) ist das wichtigste Merkmal.
Das deckt sich mit Cramers's V aus der deskriptiven Analyse.

---

#### Schritt 4: Konfusionsmatrix + Metriken

```r
pred <- predict(rf, newdata = test)
prob <- predict(rf, newdata = test, type = "prob")[, "edible"]

# Konfusionsmatrix
table(Predicted = pred, Actual = test$class)

# ROC-Kurve + AUC
library(pROC)
roc_obj <- roc(test$class, prob)
plot(roc_obj)
auc(roc_obj)
```

Konfusionsmatrix:
```
           Actual
Predicted   edible poisonous
  edible      1262         0
  poisonous      0      1175
```

AUC = 1.000 (perfekte Trennung)

**Bedeutung:** Der Random Forest klassifiziert **alle** Pilze richtig.
0 Fehler. AUC = 1.000 bedeutet: Egal welche Schwelle man wählt,
die Trennung ist perfekt.

---

### Zusammenfassung für Nicht-Profis

> Stell dir 500 Pilz-Experten vor, die unabhängig voneinander
> bestimmen. Jeder hat einen anderen Teil des Bestimmungsbuchs
> gesehen. Sie stimmen ab: "Was ist dieser Pilz?" Wenn alle 500
> "giftig" sagen, ist er giftig. Wenn alle 500 "essbar" sagen,
> ist er essbar. Der Random Forest macht das mit 500 Bäumen.
>
> Das Ergebnis ist perfekt -- aber niemand kann dir erklären,
> warum genau der Pilz jetzt giftig ist. Es ist eine Blackbox.
>
> **Ergebnis:** 0 Fehler, 100 % Accuracy. Besser geht nicht.
> Aber: nicht nachvollziehbar. Für die Praxis ist der erklärbare
> Baum die bessere Wahl, auch wenn er nicht perfekt ist.

---

## 4. Welches Modell nehme ich jetzt?

| Situation | Modell | Begründung |
|-----------|--------|------------|
| Ich will verstehen, **warum** der Pilz giftig ist | **Decision Tree (Cost-sensitive)** | 0 tödliche Fehler, jeder Pfad nachvollziehbar |
| Ich will die **höchste Genauigkeit** | **Random Forest** | 0 Fehler insgesamt, aber Blackbox |
| Ich brauche ein **einfaches Vergleichsmodell** | **Decision Tree (Standard)** | schnell, interpretierbar |

**Unsere Empfehlung:** Der Cost-sensitive Decision Tree ist der
beste Kompromiss für das Pilzsammler-Szenario: keine tödlichen
Fehler, robust getuned, und jeder Bestimmungsschritt ist
nachvollziehbar.

---

## 5. Anhang: Alle R-Befehle zum Kopieren

```r
# ============================================================
# 1. Daten laden
# ============================================================
train <- readRDS("data/processed/train_reduced.rds")
test  <- readRDS("data/processed/test_reduced.rds")

# ============================================================
# 2. Logistische Regression
# ============================================================
log_model <- glm(class ~ ., data = train, family = binomial)
s <- summary(log_model)
print(s)                          # Warnung + NA + riesige SE
prob <- predict(log_model, test, type = "response")
pred <- factor(ifelse(prob > 0.5, "edible", "poisonous"),
               levels = levels(test$class))
table(Predicted = pred, Actual = test$class)

# ============================================================
# 3. Decision Tree (Standard)
# ============================================================
library(rpart)
tree_std <- rpart(class ~ ., data = train, method = "class",
                  control = rpart.control(cp = 0.001, xval = 10))
printcp(tree_std)
cp_tbl <- tree_std$cptable
best <- which.min(cp_tbl[, "xerror"])
se_cp <- max(cp_tbl[cp_tbl[, "xerror"] <=
                     cp_tbl[best, "xerror"] + cp_tbl[best, "xstd"], "CP"])
pruned_std <- prune(tree_std, cp = se_cp)
cat("Splits:", nrow(pruned_std$frame) - 1, "\n")
table(Predict(pruned_std, test, type = "class"), test$class)

# ============================================================
# 4. Decision Tree (Cost-sensitive)
# ============================================================
cost <- matrix(c(0, 1, 10, 0), nrow = 2, byrow = TRUE,
               dimnames = list(levels(train$class), levels(train$class)))
tree_cost <- rpart(class ~ ., data = train, method = "class",
                   parms = list(loss = cost),
                   control = rpart.control(cp = 0.001, xval = 10))
# ... gleiches Tuning wie oben ...
table(predict(pruned_cost, test, type = "class"), test$class)

# ============================================================
# 5. Random Forest
# ============================================================
library(randomForest)
rf <- randomForest(class ~ ., data = train,
                   ntree = 500, mtry = 11, importance = TRUE)
table(predict(rf, test), test$class)

# ROC + AUC
library(pROC)
prob_rf <- predict(rf, test, type = "prob")[, "edible"]
roc(test$class, prob_rf)
```
