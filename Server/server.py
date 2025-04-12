from flask import Flask, jsonify, request
from flask_cors import CORS
import json
import os
import datetime
import uuid
import logging
from werkzeug.serving import run_simple

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Helper function to load JSON data
def load_data(filename):
    logger.info(f"Loading data from file: {filename}")
    file_path = os.path.join('data', filename)
    
    if not os.path.exists(file_path):
        logger.error(f"File not found: {file_path}")
        raise FileNotFoundError(f"File not found: {file_path}")
        
    with open(file_path, 'r') as f:
        data = json.load(f)
        logger.debug(f"Loaded data from {filename}: {data}")
        return data

# Route for health check
@app.route('/api/health', methods=['GET'])
def health_check():
    logger.info("Health check endpoint called")
    response = {
        'success': True,
        'message': 'Server is running',
        'data': {
            'version': '1.0.0',
            'timestamp': datetime.datetime.now().isoformat()
        }
    }
    logger.debug(f"Health check response: {response}")
    return jsonify(response)

# Get user profile
@app.route('/api/user_profile', methods=['GET'])
def get_user_profile():
    logger.info("User profile endpoint called")
    try:
        data = load_data('user_profile.json')
        response = {
            'success': True,
            'data': data,
            'message': None
        }
        logger.info(f"Successfully retrieved user profile")
        return jsonify(response)
    except Exception as e:
        error_msg = str(e)
        logger.error(f"Error retrieving user profile: {error_msg}")
        return jsonify({
            'success': False,
            'data': None,
            'message': error_msg
        }), 500

# Get itinerary data
@app.route('/api/itinerary', methods=['GET'])
def get_itinerary():
    logger.info("Itinerary endpoint called")
    try:
        data = load_data('itineraries.json')
        response = {
            'success': True,
            'data': data,
            'message': None
        }
        logger.info(f"Successfully retrieved itineraries")
        return jsonify(response)
    except Exception as e:
        error_msg = str(e)
        logger.error(f"Error retrieving itineraries: {error_msg}")
        return jsonify({
            'success': False,
            'data': None,
            'message': error_msg
        }), 500

# Generate itinerary based on provided parameters
@app.route('/api/generate_itinerary', methods=['POST'])
def generate_itinerary():
    logger.info("Generate itinerary endpoint called")
    try:
        data = request.json
        # Log the request for debugging
        logger.info(f"Generate itinerary request: {data}")
        
        # Fetch sample itinerary data
        itinerary_data = load_data('itineraries.json')
        
        # In a real app, this is where you would call an AI service to generate the itinerary
        # TODO: Implement AI-powered itinerary generation
        
        response = {
            'success': True,
            'data': itinerary_data,
            'message': 'Generated itinerary successfully'
        }
        logger.info("Successfully generated itinerary")
        return jsonify(response)
    except Exception as e:
        error_msg = str(e)
        logger.error(f"Error generating itinerary: {error_msg}")
        return jsonify({
            'success': False,
            'data': None,
            'message': error_msg
        }), 500

# Get hidden gems
@app.route('/api/hidden_gems', methods=['GET'])
def get_hidden_gems():
    logger.info("Hidden gems endpoint called")
    try:
        data = load_data('hidden_gems.json')
        response = {
            'success': True,
            'data': data,
            'message': None
        }
        logger.info(f"Successfully retrieved hidden gems")
        return jsonify(response)
    except Exception as e:
        error_msg = str(e)
        logger.error(f"Error retrieving hidden gems: {error_msg}")
        return jsonify({
            'success': False,
            'data': None,
            'message': error_msg
        }), 500

# Get local guides
@app.route('/api/local_guides', methods=['GET'])
def get_local_guides():
    logger.info("Local guides endpoint called")
    try:
        data = load_data('local_guides.json')
        response = {
            'success': True,
            'data': data,
            'message': None
        }
        logger.info(f"Successfully retrieved local guides")
        return jsonify(response)
    except Exception as e:
        error_msg = str(e)
        logger.error(f"Error retrieving local guides: {error_msg}")
        return jsonify({
            'success': False,
            'data': None,
            'message': error_msg
        }), 500

# Get festivals
@app.route('/api/festivals', methods=['GET'])
def get_festivals():
    logger.info("Festivals endpoint called")
    try:
        data = load_data('festivals.json')
        response = {
            'success': True,
            'data': data,
            'message': None
        }
        logger.info(f"Successfully retrieved festivals")
        return jsonify(response)
    except Exception as e:
        error_msg = str(e)
        logger.error(f"Error retrieving festivals: {error_msg}")
        return jsonify({
            'success': False,
            'data': None,
            'message': error_msg
        }), 500

# Get community stories
@app.route('/api/community_stories', methods=['GET'])
def get_community_stories():
    logger.info("Community stories endpoint called")
    try:
        data = load_data('community_stories.json')
        response = {
            'success': True,
            'data': data,
            'message': None
        }
        logger.info(f"Successfully retrieved community stories")
        return jsonify(response)
    except Exception as e:
        error_msg = str(e)
        logger.error(f"Error retrieving community stories: {error_msg}")
        return jsonify({
            'success': False,
            'data': None,
            'message': error_msg
        }), 500
    
@app.route('/api/hotels', methods=['GET'])
def get_hotels():
    logger.info("Hotels endpoint called")
    try:
        data = load_data('hotel_data.json')
        response = {
            'success': True,
            'data': data,
            'message': None
        }
        logger.info(f"Successfully retrieved hotels")
        return jsonify(response)
    except Exception as e:
        error_msg = str(e)
        logger.error(f"Error retrieving hotels: {error_msg}")
        return jsonify({
            'success': False,
            'data': None,
            'message': error_msg
        }), 500

# Future endpoint for AI-powered recommendations
@app.route('/api/ai_recommendations', methods=['POST'])
def ai_recommendations():
    logger.info("AI recommendations endpoint called")
    return jsonify({
        'success': False,
        'data': None,
        'message': 'This endpoint is planned for future implementation'
    }), 501

if __name__ == '__main__':
    # Ensure data directory exists
    if not os.path.exists('data'):
        os.makedirs('data')
        logger.info("Created data directory")
    
    # Check if all required data files exist
    required_files = [
        'itineraries.json',
        'user_profile.json',
        'hidden_gems.json',
        'local_guides.json',
        'festivals.json',
        'community_stories.json'
    ]
    
    missing_files = [f for f in required_files if not os.path.exists(os.path.join('data', f))]
    
    if missing_files:
        logger.warning(f"Missing data files: {', '.join(missing_files)}")
        logger.warning("Please create these files in the 'data' directory before running the server")
    
    logger.info("Starting Flask server on http://0.0.0.0:6969")
    run_simple('0.0.0.0', 6969, app, use_reloader=True, use_debugger=True)