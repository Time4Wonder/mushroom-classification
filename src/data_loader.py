import pandas as pd
from ucimlrepo import fetch_ucirepo
import os

def load_raw_mushroom_data():
    """
    Fetches the mushroom dataset from UCI repository.
    """
    print("Fetching mushroom dataset (ID: 73)...")
    mushroom = fetch_ucirepo(id=73)
    
    X = mushroom.data.features
    y = mushroom.data.targets
    
    # Combine into one dataframe for raw storage/inspection
    df_raw = pd.concat([X, y], axis=1)
    
    # Save raw data for persistence if directory exists
    raw_path = "data/raw/mushroom_raw.csv"
    if os.path.exists("data/raw"):
        df_raw.to_csv(raw_path, index=False)
        print(f"Raw data saved to {raw_path}")
        
    return X, y

if __name__ == "__main__":
    X, y = load_raw_mushroom_data()
    print(X.head())
