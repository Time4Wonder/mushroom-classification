# Train/Test-Split — Mushroom Dataset

## 1. Zweck

Gemäß Kapitel 5.5 der Vorlesung (Trainings- und Testdatensatz) muss für eine valide Bewertung der Prognosegenauigkeit der Datensatz in zwei getrennte Teile aufgeteilt werden:

> *"Aus der Genauigkeit dieser Prognosen folgt, wie gut das Modell f die Realität abbildet: je genauer die Prognosen, desto besser das Modell. Um die Genauigkeit von Prognosen zu errechnen, darf man nicht denselben Datensatz verwenden, mit dem das Modell schon berechnet wurde."*

- **Trainingsdatensatz** (70 %) — wird zum Berechnen der Modelle verwendet
- **Testdatensatz** (30 %) — wird ausschließlich für die finale Evaluation der Modelle verwendet

## 2. Methodik

### Stratifizierter Split

Da die Zielvariable `class` mit 51,8 % (edible) / 48,2 % (poisonous) leicht imbalance ist, wurde ein **stratifizierter Split** durchgeführt. Dabei werden die Proportionen beider Klassen in Trainings- und Testdatensatz gleichermaßen erhalten.

### Implementierung


1. Für jede Klasse (`edible`, `poisonous`) werden 70 % der Indizes zufällig ausgewählt
2. Die ausgewählten Indizes werden kombiniert und sortiert
3. Alle Zeilen an diesen Indizes bilden den Trainingsdatensatz, die restlichen 30 % den Testdatensatz

### Reproduzierbarkeit

```r
set.seed(467)
```

Der Seed `467` entspricht dem Wert aus dem Prototyp (`virt/mushroom.r`) und gewährleistet reproduzierbare Ergebnisse.

## 3. Ergebnisse

| Datensatz | Zeilen | edible | poisonous | Anteil edible |
|---|---|---|---|---|
| Gesamt | 8.124 | 4.208 | 3.916 | 51,8 % |
| Training (70 %) | 5.687 | 2.946 | 2.741 | 51,8 % |
| Test (30 %) | 2.437 | 1.262 | 1.175 | 51,8 % |

Die Klassenproportionen bleiben im Trainings- und Testdatensatz nahezu identisch zur Gesamtverteilung.

## 4. Wichtige Hinweise

> **Die Testdaten werden ausschließlich für die finale Evaluation verwendet.**  
> Jegliches Tuning von Parametern auf dem Testdatensatz würde die Ergebnisse verfälschen. Die Vorlesung (Kap. 5.5, Kap. 6.1) betont:
>
> *"Durch das Tunen auf dem Testdatensatz haben wir den Testdatensatz als Validierungsdatensatz missbraucht. Dadurch ist die auf dem Testdatensatz ermittelte Prognosegüte nicht mehr verlässlich."*

Das Tuning der Modellparameter erfolgt stattdessen durch **10-fache Kreuzvalidierung** ausschließlich auf dem Trainingsdatensatz (vgl. Kapitel 6.3 der Vorlesung).
