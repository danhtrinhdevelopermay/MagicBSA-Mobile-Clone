#!/bin/bash

# Start the Twink Video Backend API server
echo "🚀 Starting Twink Video Backend API..."
echo "📍 Health check: http://localhost:5000/api/health"
echo "🎬 Video jobs: http://localhost:5000/api/video-jobs"
echo "📱 Event banners: http://localhost:5000/api/event-banners"
echo ""

# Set environment for development
export NODE_ENV=development

# Start the server
npx tsx server/index.ts