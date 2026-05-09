from src.data_loader import load_raw_mushroom_data
from src.preprocessing import preprocess_mushroom_data

def main():
    print("=== Mushroom Data Preparation Pipeline ===")
    
    # 1. Load
    X, y = load_raw_mushroom_data()
    
    # 2. Preprocess
    X_train, X_test, y_train, y_test, label_encoder = preprocess_mushroom_data(X, y)
    
    print("\nSuccess! Data is ready for Machine Learning.")
    print(f"Training features: {X_train.shape}")
    print(f"Test features:     {X_test.shape}")
    print(f"Target classes:    {list(label_encoder.classes_)} mapped to [0, 1]")
    print("\nYou can now find the processed CSV files in 'data/processed/'.")
    print("Or import these variables directly into your model training script.")

if __name__ == "__main__":
    main()
