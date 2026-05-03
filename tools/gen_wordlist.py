import sys

def generate_passwords():
    seasons = ["Spring", "Summer", "Autumn", "Winter", "October", "Fall", "Halloween", "Season"]
    years = range(2022, 2025)

    with open("custom_seasons.txt", "w") as f:
        for year in years:
            for season in seasons:
                # Capitalized: SeasonYear!
                f.write(f"{season}{year}!\n")
                # Lowercase: seasonyear!
                f.write(f"{season.lower()}{year}!\n")

if __name__ == "__main__":
    generate_passwords()
    print("Generated custom SeasonYear! & seasonyear! password list -> ./custom_seasons.txt")
