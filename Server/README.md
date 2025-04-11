# HimYatra: Himachal Pradesh Tourism App

A modular iOS app for exploring and planning trips to Himachal Pradesh with a Flask backend API.

## Project Structure

The project is divided into two main components:

1. **iOS Swift App**: A modular SwiftUI application
2. **Flask API Server**: A backend server providing data via API endpoints

### Swift App Files

- `ContentView.swift` - Main app container with tab view
- `Models.swift` - All data models
- `PlanView.swift` - Plan tab implementation
- `MapView.swift` - Map tab implementation
- `DiscoverView.swift` - Discover tab implementation
- `PassportView.swift` - Passport tab implementation
- `ViewModels.swift` - All ViewModel classes
- `APIService.swift` - Network service for API requests

### Flask Server Files

- `server.py` - Main Flask application
- `data/` directory containing JSON data:
  - `itineraries.json` - Itinerary data
  - `user_profile.json` - User profile information
  - `hidden_gems.json` - Hidden gem locations
  - `local_guides.json` - Local guide information
  - `festivals.json` - Festival information
  - `community_stories.json` - Community stories

## Setting Up the Project

### Prerequisites

- Xcode 14+ for iOS development
- Python 3.8+ for Flask server
- pip for Python package management

### Setting up the Flask Server

1. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. Install required packages:
   ```bash
   pip install flask flask-cors
   ```

3. Create the data directory and JSON files:
   ```bash
   mkdir data
   # Copy the JSON files into the data directory
   ```

4. Start the server:
   ```bash
   python server.py
   ```

The server will run on http://localhost:5000 by default.

### Setting up the iOS App

1. Open the project in Xcode
2. Update the base URL in `APIService.swift` if needed (default is http://localhost:5000)
3. Build and run the app on a simulator or device

## Future Enhancements

Currently, the server provides static JSON data. Future plans include:

1. Integration with an AI service to dynamically generate personalized itineraries
2. Real-time weather and road condition updates
3. User authentication and personalized recommendations
4. Image upload capabilities for user contributions
5. Social sharing features

## AI Integration Plan

The `server.py` file includes a commented placeholder endpoint for AI integration. In the future, this will:

1. Use LLMs (e.g., GPT-4) to generate custom itineraries based on user preferences
2. Analyze user behavior to provide personalized recommendations
3. Augment the static data with dynamic, AI-generated content
4. Handle natural language queries about destinations

## Adding More Data

To add more data, simply edit the JSON files in the `data` directory. The server will automatically serve the updated data.