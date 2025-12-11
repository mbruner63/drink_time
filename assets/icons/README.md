# Icon Placeholder

Since the automated icon generation had issues, here are the steps to create the app icon:

## Manual Creation Steps:

1. **Open the HTML generator**: Open `create_icon.html` in your browser
2. **Take a screenshot** of the icon displayed
3. **Resize to 1024x1024** pixels using any image editor
4. **Save as** `app_icon_1024.png` in this directory

## Alternative - Use this description for design tools:

**DrinkTime App Icon Design:**
- **Size**: 1024x1024 pixels
- **Background**: Rounded rectangle (22% radius) with sky blue gradient (#87CEEB to #4682B4)
- **Center**: Semi-transparent steel blue circle
- **Text**: White "DT" text, bold, centered, ~350px font size
- **Corner icon**: Orange circle (#FF8C00) in bottom-right with white martini glass icon

Once you have the icon file, run:
```bash
dart run flutter_launcher_icons
```