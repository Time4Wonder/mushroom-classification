- CV
- glm
  - 4 perfect seperation merkmale
  - was heißt deterministisch im datensatzkontext? 
- decsision tree
  - rpart
  - Cost Complexity Pruning (Weakest Link Pruning) 
    - cp (copmplexity parameter) splits
      - cp = 0.001
    - 1 SE - Rege 
  - 1 SE "1 Standard Errror Rule 
    - ich schaue auf die niedrigste fehlerrate berechne den Standardfehler und schaue welches kleinere model innerhalb dieser liegt.

- random forest
  - bagging (bootstrap + aggregation)
  - feature bagging
    - mit 10-cv-validation die mtry rausgefunden 11 hat gewonnen
  - aggregation

  - Variable IMPORTANce
  >   - MeanDecreaseAccuracy -> wie wichtig ist das merkmal für die prognose
      - MeanDecreaseGini -> Welches Merkmal hat oft für gute splits gesorgt.

  - OOB (Out of Bag): 
      - Testset mit den daten 37%
  - AUC Area under the Curve
    - Area unter ROC-kurve 
- Lasso ? 
