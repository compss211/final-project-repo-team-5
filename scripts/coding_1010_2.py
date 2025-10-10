import pandas as pd
import numpy as np
import os
import matplotlib.pyplot as plt
import seaborn as sns
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer # 导入 VADER

# --- 1. Define File Paths ---
# [中文解释]: 定义文件路径。base_path 是 D:\... 目录，file_name 是 CSV 文件名。
# 使用 os.path.join 确保路径在 Windows 上正确连接，并假设文件在 'data' 子文件夹内。
base_path = r'D:\zhannie\2025-2026 UCB MaCSS\fall course\advanced computing\COMPSS-211'
file_name = 'Chatgpt_Tweets_Nov30_Feb11.csv'
file_path = os.path.join(base_path, 'data', file_name) 

# --- 2. Location Cleaning Function ---
# [中文解释]: 地理位置清洗函数。将常见的缩写和乱码标准化为统一的名称。
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

# --- 3. Sentiment Analysis Function ---
# [中文解释]: 情感分析函数。使用 VADER 库为每条推文计算复合情感分数 (Compound Score)。
analyzer = SentimentIntensityAnalyzer()
def get_sentiment_score(text):
    """Returns the VADER compound sentiment score for a given text."""
    if pd.isna(text):
        return 0.0
    # VADER works best on strings, convert text to string
    score = analyzer.polarity_scores(str(text))
    # Compound score is the normalized, weighted composite score
    return score['compound']

# --- 4. Main Data Processing and Analysis Pipeline ---

print("--- Step 1: Loading Data ---")
# [中文解释]: 尝试加载数据。使用 encoding='latin1' 解决之前的编码错误。
print(f"Attempting to load file from path: {file_path}")
try:
    df = pd.read_csv(file_path, encoding='latin1')
    print(f"Data successfully loaded! Total rows: {len(df)}")
except Exception as e:
    print(f"ERROR during file loading: {e}")
    exit()

print("\n--- Step 2: Data Preprocessing ---")
# [中文解释]: 清洗 location 列，创建 'location_cleaned' 新列。
df['location_cleaned'] = df['location'].apply(standardize_location)

# [中文解释]: 格式化 'date' 列，提取每日日期。
df['date'] = pd.to_datetime(df['date'], errors='coerce') 
df['only_date'] = df['date'].dt.date

# --- 5. Sentiment Analysis ---
print("\n--- Step 3: Performing Sentiment Analysis ---")
# [中文解释]: 对 'Text' 列应用情感分析函数，生成 'sentiment_score' 列。
df['sentiment_score'] = df['Text'].apply(get_sentiment_score)
print(f"Sentiment analysis complete. Sample scores (First 5):")
print(df[['Text', 'sentiment_score']].head())


# --- 6. Data Aggregation for Visualizations ---

print("\n--- Step 4: Data Aggregation ---")

# Aggregation 1: Daily Tweet Volume (Temporal Heat)
# [中文解释]: 计算每天的推文总数。
daily_counts = df.groupby('only_date').size().reset_index(name='tweet_count')
daily_counts['only_date'] = pd.to_datetime(daily_counts['only_date'])

# Aggregation 2: Daily Average Sentiment (Attitude Change)
# [中文解释]: 计算每天的平均情感分数。
daily_sentiment = df.groupby('only_date')['sentiment_score'].mean().reset_index(name='avg_sentiment')
daily_sentiment['only_date'] = pd.to_datetime(daily_sentiment['only_date'])

# Aggregation 3: Top Locations
# [中文解释]: 统计清洗后推文数最多的前 10 个地点。
top_locations = df['location_cleaned'].value_counts().head(10)


# --- 7. Data Visualization ---

print("\n--- Step 5: Data Visualization ---")

# Visualization 1: Top 10 Geographical Hotspots (Bar Plot)
# [中文解释]: 绘制条形图，显示清洗后推文数量最多的前 10 个地理位置。
plt.figure(figsize=(10, 6))
sns.barplot(x=top_locations.values, y=top_locations.index, palette="viridis")
plt.title('Top 10 Geographical Hotspots for ChatGPT Tweets')
plt.xlabel('Number of Tweets')
plt.ylabel('Location')
plt.grid(axis='x', linestyle='--', alpha=0.6)
plt.tight_layout()
plt.show() 

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
plt.show() 

# Visualization 3: Average Attitude Change Over Time (Line Plot)
# [中文解释]: 绘制线图，显示平均情感分数随时间的变化。这是回答“态度转变”问题的核心图表。
plt.figure(figsize=(12, 6))
sns.lineplot(x='only_date', y='avg_sentiment', data=daily_sentiment, color='darkgreen')
plt.title('Average Attitude Change Towards ChatGPT Over Time')
plt.xlabel('Date')
plt.ylabel('Average Sentiment Score (Positive > 0 > Negative)')
plt.axhline(y=0, color='r', linestyle='--', alpha=0.6, label='Neutral Line') # Add a neutral line
plt.xticks(rotation=45)
plt.legend()
plt.grid(True, linestyle='--', alpha=0.7)
plt.tight_layout()
plt.show() 

# --- Summary and Conclusion ---
print("\n--- Analysis Complete ---")
print("All data processing, cleaning, sentiment analysis, and visualization steps are complete.")
print("The third graph now shows the core insight: **How public attitude is changing over time.**")