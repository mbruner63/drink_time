#!/usr/bin/env python3
"""
Simple DrinkTime app icon generator
Creates a 1024x1024 PNG icon based on the design concepts
"""

try:
    from PIL import Image, ImageDraw, ImageFont
    import io
    import os
except ImportError:
    print("PIL not available. Please install with: pip install pillow")
    exit(1)

def create_app_icon():
    # Create 1024x1024 image
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Colors
    sky_blue = (135, 206, 235)      # #87CEEB
    steel_blue = (70, 130, 180)     # #4682B4
    dark_orange = (255, 140, 0)     # #FF8C00
    white = (255, 255, 255)

    # Create rounded rectangle background
    margin = size * 0.05  # 5% margin for rounded corners
    draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=size * 0.22,
        fill=sky_blue
    )

    # Inner circle for depth
    center = size // 2
    circle_radius = size * 0.35
    circle_bbox = [
        center - circle_radius, center - circle_radius,
        center + circle_radius, center + circle_radius
    ]
    # Create semi-transparent overlay
    overlay = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay)
    overlay_draw.ellipse(circle_bbox, fill=steel_blue + (80,))  # 80 alpha
    img = Image.alpha_composite(img, overlay)
    draw = ImageDraw.Draw(img)

    # Draw "DT" text
    try:
        # Try to use a bold system font
        font_size = int(size * 0.35)
        try:
            font = ImageFont.truetype("arial.ttf", font_size)
        except:
            try:
                font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", font_size)
            except:
                font = ImageFont.load_default()
    except:
        font = ImageFont.load_default()

    text = "DT"
    # Get text bbox to center it
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    text_x = (size - text_width) // 2
    text_y = (size - text_height) // 2

    # Draw text shadow
    shadow_offset = size // 80
    draw.text((text_x + shadow_offset, text_y + shadow_offset), text,
              fill=(0, 0, 0, 80), font=font)

    # Draw main text
    draw.text((text_x, text_y), text, fill=white, font=font)

    # Draw small drink icon circle
    glass_center_x = size * 0.78
    glass_center_y = size * 0.78
    glass_radius = size * 0.09
    glass_bbox = [
        glass_center_x - glass_radius, glass_center_y - glass_radius,
        glass_center_x + glass_radius, glass_center_y + glass_radius
    ]
    draw.ellipse(glass_bbox, fill=dark_orange)

    # Draw simple martini glass shape
    glass_size = glass_radius * 0.6
    # Triangle for glass bowl
    triangle_points = [
        (glass_center_x - glass_size * 0.5, glass_center_y - glass_size * 0.3),
        (glass_center_x + glass_size * 0.5, glass_center_y - glass_size * 0.3),
        (glass_center_x, glass_center_y + glass_size * 0.2)
    ]
    draw.polygon(triangle_points, fill=white)

    # Glass stem
    stem_width = max(2, size // 200)
    draw.line([
        (glass_center_x, glass_center_y + glass_size * 0.2),
        (glass_center_x, glass_center_y + glass_size * 0.5)
    ], fill=white, width=stem_width)

    # Glass base
    base_width = glass_size * 0.4
    base_thickness = max(3, size // 150)
    draw.line([
        (glass_center_x - base_width, glass_center_y + glass_size * 0.5),
        (glass_center_x + base_width, glass_center_y + glass_size * 0.5)
    ], fill=white, width=base_thickness)

    # Save the image
    os.makedirs('assets/icons', exist_ok=True)
    img.save('assets/icons/app_icon_1024.png', 'PNG')
    print("App icon created: assets/icons/app_icon_1024.png")

if __name__ == "__main__":
    create_app_icon()