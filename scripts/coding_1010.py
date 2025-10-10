import pandas as pd
import numpy as np
import os # <-- Must import os library to use os.path.join

# --- 1. Define File Paths ---
# This is the base path you provided: D:\zhannie\2025-2026 UCB MaCSS\fall course\advanced computing\COMPSS-211
base_path = r'D:\zhannie\2025-2026 UCB MaCSS\fall course\advanced computing\COMPSS-211'
file_name = 'Chatgpt_Tweets_Nov30_Feb11.csv'  # <--- Ensure this line exists!

# Use os.path.join to construct the full CSV file path, assuming the file is in the 'data' subfolder.
file_path = os.path.join(base_path, 'data', file_name) 

# --- 2. Location Cleaning Function ---
def standardize_location(location_str):
    """
    清洗和标准化常见的地理位置乱码/缩写。
    """
    if pd.isna(location_str):
        return 'Unknown'

    loc = str(location_str).lower().strip()

    # 常见乱码/缩写替换字典 (可以根据数据持续扩展)
    replacements = {
        'jed ksa': 'Jeddah, Saudi Arabia',
        'cape tow': 'Cape Town, South Africa',
        'london, e': 'London, UK',
        'uk': 'United Kingdom',
        'usa': 'United States',
        'ny': 'New York, United States',
        'tx': 'Texas, United States',
    }

    for messy, clean in replacements.items():
        if messy in loc:
            return clean

    # 对于没有匹配到的，统一进行首字母大写处理
    return loc.title()

# --- 3. Main Data Processing Pipeline ---
print("--- Step 1: Loading Data ---")
print(f"Attempting to load file from path: {file_path}")
try:
    # Attempt to load data using 'latin1' encoding to resolve the decoding error.
    df = pd.read_csv(file_path, encoding='latin1')
    print(f"Data successfully loaded! Total rows: {len(df)}")

except FileNotFoundError:
    print(f"ERROR: File path '{file_path}' not found. Please verify the file's location.")
    exit()
except Exception as e:
    print(f"ERROR during file loading: {e}")
    exit()

# --- Location Cleaning ---
print("\n--- Step 2: Cleaning Geographical Data ---")
# Apply the cleaning function to the 'location' column
df['location_cleaned'] = df['location'].apply(standardize_location)

print("Comparison of Location (First 10 Rows):")
print(df[['location', 'location_cleaned']].head(10))

# Count the top 10 locations after cleaning (for geographical analysis)
top_locations = df['location_cleaned'].value_counts().head(10)
print("\nTop 10 Locations by Tweet Count (Cleaned):")
print(top_locations)

# --- Preparation for Time Analysis ---
print("\n--- Step 3: Preparing Time Data (Date Formatting) ---")
# Convert the 'date' column to datetime objects
df['date'] = pd.to_datetime(df['date'], errors='coerce') 

# Extract the date only for daily aggregation
df['only_date'] = df['date'].dt.date

# Calculate the number of tweets per day (for analyzing trend heat)
daily_counts = df.groupby('only_date').size().reset_index(name='tweet_count')
print("Daily Tweet Counts (First 5 Rows):")
print(daily_counts.head())

# --- Summary and Next Step ---
print("\n--- Summary ---")
print("Data loading, geographical cleaning, and temporal preparation are complete.")
print("Next Step: Implement sentiment analysis to score each tweet and track attitude changes over time.")


import pandas as pd
import numpy as np
import os
import matplotlib.pyplot as plt
import seaborn as sns 

# --- 1. Define File Paths ---
# [中文解释]: 定义文件路径。base_path 是 D:\... 目录，file_name 是 CSV 文件名。
# 使用 os.path.join 确保路径在 Windows 上正确连接，并假设文件在 'data' 子文件夹内。
base_path = r'D:\zhannie\2025-2026 UCB MaCSS\fall course\advanced computing\COMPSS-211'
file_name = 'Chatgpt_Tweets_Nov30_Feb11.csv'
file_path = os.path.join(base_path, 'data', file_name) 

# --- 2. Location Cleaning Function ---
# [中文解释]: 地理位置清洗函数。将常见的缩写和乱码标准化为统一的名称，便于分析。
def standardize_location(location_str):
    """Cleans and standardizes common messy location strings."""
    if pd.isna(location_str):
        return 'Unknown'
    loc = str(location_str).lower().strip()
    replacements = {
        'jed ksa': 'Jeddah, Saudi Arabia', 'cape tow': 'Cape Town, South Africa',
        'london, e': 'London, UK', 'uk': 'United Kingdom', 'usa': 'United States',
        'ny': 'New York, United States', 'tx': 'Texas, United States',
    }
    for messy, clean in replacements.items():
        if messy in loc:
            return clean
    return loc.title()

# --- 3. Main Data Processing Pipeline ---
print("--- Step 1: Loading Data ---")
# [中文解释]: 尝试加载数据。使用 encoding='latin1' 解决之前的编码错误。
print(f"Attempting to load file from path: {file_path}")
try:
    df = pd.read_csv(file_path, encoding='latin1')
    print(f"Data successfully loaded! Total rows: {len(df)}")
except Exception as e:
    print(f"ERROR during file loading: {e}")
    exit()

print("\n--- Step 2: Cleaning Geographical Data ---")
# [中文解释]: 清洗 location 列，创建 'location_cleaned' 新列，并统计推文数最多的前 10 个地点。
df['location_cleaned'] = df['location'].apply(standardize_location)
top_locations = df['location_cleaned'].value_counts().head(10)
print("Top 10 Locations by Tweet Count (Cleaned):\n", top_locations)

print("\n--- Step 3: Preparing Time Data ---")
# [中文解释]: 将 'date' 列转换为日期时间格式，提取出每日日期，并计算每天的推文总数（热度）。
df['date'] = pd.to_datetime(df['date'], errors='coerce') 
df['only_date'] = df['date'].dt.date
daily_counts = df.groupby('only_date').size().reset_index(name='tweet_count')
daily_counts['only_date'] = pd.to_datetime(daily_counts['only_date']) # Convert back for plotting
print("Daily Tweet Counts (First 5 Rows):\n", daily_counts.head())

# --- 4. Data Visualization ---

print("\n--- Step 4: Data Visualization ---")

# Visualization 1: Top 10 Geographical Hotspots (Bar Plot)
# [中文解释]: 绘制条形图，显示清洗后推文数量最多的前 10 个地理位置。
plt.figure(figsize=(10, 6))
sns.barplot(x=top_locations.values, y=top_locations.index, palette="viridis")
plt.title('Top 10 Geographical Hotspots for ChatGPT Tweets')
plt.xlabel('Number of Tweets')
plt.ylabel('Location')
plt.grid(axis='x', linestyle='--', alpha=0.6)
plt.tight_layout()
plt.show() # Display the location plot

# Visualization 2: Tweet Volume Over Time (Line Plot)
# [中文解释]: 绘制线图，显示每天的推文数量变化，用于观察讨论热度的时间趋势和峰值。
plt.figure(figsize=(12, 6))
sns.lineplot(x='only_date', y='tweet_count', data=daily_counts, color='darkorange')
plt.title('Daily Tweet Volume for ChatGPT (Temporal Heat)')
plt.xlabel('Date')
plt.ylabel('Number of Tweets')
plt.xticks(rotation=45)
plt.grid(True, linestyle='--', alpha=0.7)
plt.tight_layout()
plt.show() # Display the temporal plot

# --- Summary and Next Step ---
print("\n--- Summary ---")
print("Visualizations for **Geographical Hotspots** and **Temporal Heat** are displayed.")
print("The next critical step is to perform **Sentiment Analysis** to quantify 'attitude'.")
print("Do you want the Python code to implement **Sentiment Analysis**?")