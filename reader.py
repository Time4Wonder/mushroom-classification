import pandas as pd
from ucimlrepo import fetch_ucirepo 

# 1. Daten laden
mushroom = fetch_ucirepo(id=73) 
X = mushroom.data.features 
y = mushroom.data.targets 
df = pd.concat([y, X], axis=1)

