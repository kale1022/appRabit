# app_rabbit

A new Flutter project.

## Getting Started

# Image Search App

A single-page Flutter application that allows users to search for images using the Pixabay API. The app features a search bar with debounce functionality and infinite scroll for seamless browsing.

## Features

- 🔍 **Search Bar**: Real-time image search with debounce (500ms delay)
- 📤 **AI Image Upload**: Upload photos and find similar images using Gemini AI (FREE model)
- 🤖 **Smart Analysis**: AI converts uploaded images into search prompts using free Gemini 2.5 Flash
- 📱 **Mobile-Friendly Design**: Responsive layout optimized for mobile devices
- ♾️ **Infinite Scroll**: Automatically loads more images as you scroll
- 🖼️ **Image Grid**: Beautiful 2-column grid layout with image cards
- 🎨 **Modern UI**: Clean, Material Design 3 interface with animations
- 🚀 **Performance**: Cached network images for smooth scrolling
- 🔄 **Random Images**: Load random images when no search query is provided

## Requirements Met

✅ Search bar at the top  
✅ List of results below  
✅ Images sourced from Pixabay API  
✅ Infinite scroll implementation  
✅ Debounce in the search field  
✅ Mobile-friendly design  

## Technologies Used

- **Flutter**: Cross-platform mobile framework
- **HTTP**: For API requests
- **Cached Network Image**: For efficient image loading and caching
- **Pixabay API**: For high-quality image search
- **Google Generative AI**: For AI-powered image analysis
- **Image Picker**: For photo uploads from gallery or camera

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd app_rabbit
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### API Key Setup (Required)

This app requires two API keys to function:

1. **Pixabay API Key** (for image search):
   - Get a free API key from [Pixabay API](https://pixabay.com/api/docs/)

2. **Gemini API Key** (for AI image analysis - FREE model):
   - Get a free API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
   - We use `gemini-2.5-flash-image-preview` which is completely free

3. Copy the `.env.example` file to `.env`:
   ```bash
   cp .env.example .env
   ```

4. Edit the `.env` file and add your API keys:
   ```
   PIXABAY_API=your_pixabay_api_key_here
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

**Important**: The `.env` file is gitignored and will not be committed to the repository for security.

### Security Notes

- ✅ **API keys are never committed** to version control
- ✅ **Environment variables only** - no hardcoded secrets
- ✅ **Gitignore protection** - `.env` files are automatically excluded
- ✅ **Clear error messages** if API key is missing

For more security information, see [SECURITY.md](SECURITY.md).

## Project Structure

```
lib/
├── main.dart                 # Main application entry point
├── models/
│   └── image_model.dart     # Image data model
├── services/
│   └── image_service.dart   # API service for image search
└── widgets/
    ├── debounced_search_field.dart  # Search input with debounce
    └── image_grid.dart             # Grid layout for images
```

## Usage

1. **Search Images**: Type in the search bar to find specific images
2. **Browse Random**: Clear the search to see random images
3. **Infinite Scroll**: Scroll down to automatically load more images
4. **Refresh**: Tap the floating action button to load new random images

## Features Implementation

### Debounce Search
The search field implements a 500ms debounce to prevent excessive API calls while typing.

### Infinite Scroll
Images are loaded in batches of 20, with automatic loading triggered when the user scrolls near the bottom.

### Error Handling
Comprehensive error handling with user-friendly error messages displayed via SnackBar.

### Performance Optimization
- Cached network images for smooth scrolling
- Efficient grid layout with proper aspect ratios
- Lazy loading of images

## Demo

The app is ready to run and will display random images on startup. Try searching for terms like "nature", "architecture", "food", etc.

## License

This project is created as a coding challenge demonstration.
