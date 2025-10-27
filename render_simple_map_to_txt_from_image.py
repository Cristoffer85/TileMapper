from PIL import Image

# --- CONFIG ---
input_image = "src/assets/img/europe.png"           # Path to your input image
output_txt = "src/assets/map/MainWorld2.txt"        # Output file for your map
land_tile = "0:61"                                  # Tile ID for land
sea_tile = "0:1"                                    # Tile ID for sea
size = 256                                          # Size of the output map (size x size)
# --------------




img = Image.open(input_image).convert("L").resize((size, size), Image.LANCZOS)
pixels = img.load()

with open(output_txt, "w") as f:
    for y in range(size):
        row = []
        for x in range(size):
            val = land_tile if pixels[x, y] < 200 else sea_tile  # threshold: adjust if needed
            row.append(val)
        f.write(",".join(row) + ",\n")

print(f"Done! Saved to {output_txt}")