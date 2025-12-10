# Turning my JSON files into CSV files for easier analysis
import json
import csv
import os

def json_to_csv(json_path, csv_path):
    """Convert a JSON file containing a list of dicts to CSV."""
    # Check file existence
    if not os.path.exists(json_path):
        print(f"❌ JSON file not found: {json_path}")
        return

    # Open the JSON file and load the data
    with open(json_path, 'r', encoding='utf-8') as json_file:
        data = json.load(json_file)

    # Open the CSV file for writing
    with open(csv_path, 'w', newline='', encoding='utf-8') as csv_file:
        if not data:
            print("⚠️ No data found in JSON file.")
            return

        # Create a CSV writer object
        writer = csv.writer(csv_file)

        # Write the header row (keys of the first dictionary)
        header = data[0].keys()
        writer.writerow(header)

        # Write the data rows
        for entry in data:
            writer.writerow(entry.values())

    print(f"✅ Data successfully written to {csv_path}")


# ============================
# Run the conversion
# ============================
json_file = "/Users/isabellalatchamradusky/Documents/GitHub/final-project-repo-team-5/blueskyapistuff/test_ai_posts_historical.json"
csv_file = "/Users/isabellalatchamradusky/Documents/GitHub/final-project-repo-team-5/blueskyapistuff/test_ai_posts_historical.csv"

json_to_csv(json_file, csv_file)
