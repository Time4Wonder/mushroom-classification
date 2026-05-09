import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
import os

def preprocess_mushroom_data(X, y, test_size=0.2, random_state=42):
    """
    Preprocesses the mushroom dataset for Machine Learning.
    - Handles missing values ('?') by treating them as a category.
    - One-Hot Encodes categorical features.
    - Label Encodes the target (e/p).
    """
    print("Starting preprocessing...")
    
    # 1. Encoding Features (X)
    # Since all features are categorical, One-Hot Encoding is standard.
    # Note: '?' is kept as a unique category because its absence can be informative.
    X_encoded = pd.get_dummies(X, columns=X.columns, drop_first=True)
    
    # 2. Encoding Target (y)
    # poisonous -> 1, edible -> 0
    le = LabelEncoder()
    y_encoded = le.fit_transform(y.values.ravel())
    y_series = pd.Series(y_encoded, name='target')
    
    # 3. Splitting
    X_train, X_test, y_train, y_test = train_test_split(
        X_encoded, y_series, test_size=test_size, random_state=random_state, stratify=y_encoded
    )
    
    # 4. Optional: Save processed data
    if os.path.exists("data/processed"):
        X_train.to_csv("data/processed/X_train.csv", index=False)
        X_test.to_csv("data/processed/X_test.csv", index=False)
        y_train.to_csv("data/processed/y_train.csv", index=False)
        y_test.to_csv("data/processed/y_test.csv", index=False)
        print("Processed data saved to data/processed/")
        
    return X_train, X_test, y_train, y_test, le

if __name__ == "__main__":
    # This part is just for testing the module independently
    from data_loader import load_raw_mushroom_data
    X, y = load_raw_mushroom_data()
    preprocess_mushroom_data(X, y)
