# AI Image Editor Flutter App - Android Project

## Overview

This is a feature-rich Flutter mobile application that provides AI-powered image editing capabilities through various API integrations. The app offers professional-grade image processing tools including background removal, object cleanup, image enhancement, text-to-image generation, and now includes a new AI video creation from images feature. Built primarily for Android with a modern Material Design interface, the application integrates multiple AI services including ClipDrop API, Hugging Face models, and specialized image processing APIs.

## Recent Changes

**Date: August 03, 2025**
- Added banner slide system for displaying events and promotions
- Created AI video creation from images feature that sends requests to admin team for processing
- Cleaned up project by removing all web components, keeping only Android Flutter app
- Added new models: EventBanner and VideoJob for the banner system
- Created EventBannerSlider widget with auto-sliding functionality
- Added AIVideoCreationScreen with comprehensive form for video requests
- Updated dependencies to include cached_network_image for banner image loading
- **NEW**: Built complete web backend with Express.js for handling video creation requests
- **NEW**: Configured PostgreSQL database with video_jobs and event_banners tables
- **NEW**: Integrated SendGrid email service for admin notifications and user responses
- **NEW**: Created comprehensive API endpoints for mobile app integration
- **NEW**: Set up admin workflow for manual video processing and status updates
- **LATEST**: Fixed database connectivity and server configuration
- **LATEST**: Server is now running successfully on port 5000 with health check at /api/health
- **LATEST**: Created loinhac.md file with important Git and APK build guidelines
- **LATEST**: Database tables successfully created and API endpoints are functional
- **NEW**: Configured complete deployment setup for Render platform
- **NEW**: Created render-package.json with proper build/start scripts for production
- **NEW**: Generated comprehensive deployment guide with all environment variables
- **NEW**: Setup Flutter integration guide for production backend URL: https://web-backend_0787twink.onrender.com
- **NEW**: Configured SendGrid email service with provided credentials
- **NEW**: All environment variables documented for Render deployment

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Frontend Architecture
- **Framework**: Flutter 3.22.0+ with Dart programming language
- **UI Pattern**: Material Design with custom widgets and screens
- **State Management**: Provider pattern for reactive state management
- **Navigation**: MaterialPageRoute-based navigation between screens
- **Media Handling**: Video player integration with custom controllers and asset preloading
- **Image Processing**: Local image manipulation using the `image` package for resizing and format conversion
- **Banner System**: Event banner slider with auto-rotation and tap navigation

### Backend Architecture
- **API Layer**: Service-oriented architecture with dedicated service classes for each AI provider
- **HTTP Client**: Dio package for robust HTTP requests with interceptors and error handling
- **File Management**: Temporary file handling for image processing pipelines
- **Background Processing**: Async/await patterns with loading states and progress tracking
- **Video Job Processing**: Admin-based processing system for AI video creation requests

### Core Features Structure
- **Image Upload & Preview**: Camera and gallery integration with image picker
- **AI Processing Pipeline**: Multi-step image processing with automatic resizing based on API constraints
- **Result Management**: Save, share, and history tracking of processed images
- **Settings Management**: SharedPreferences for API keys and user preferences
- **Event Banner System**: Dynamic banner slider for promotions and new features
- **AI Video Creation**: Request-based video generation system with admin processing

### Authentication and Authorization
- **API Key Management**: Secure storage of multiple API keys with failover mechanisms
- **Token Validation**: API key validation and credit/quota monitoring
- **Access Control**: Premium feature flagging and usage tracking

## New Features Added

### Banner Slide System
- **EventBanner Model**: Complete data model for banner management
- **EventBannerSlider Widget**: Auto-sliding banner carousel with custom styling
- **Integration**: Seamlessly integrated into main screen above feature grid
- **Navigation**: Tap-to-navigate functionality for banner actions

### AI Video Creation Feature
- **VideoJob Model**: Data structure for video creation requests
- **AIVideoCreationScreen**: Comprehensive form for video creation requests
- **Features**: 
  - Image upload with preview
  - Video style selection (Cinematic, Anime, Realistic, Artistic, Vintage, Futuristic)
  - Duration selection (3s, 5s, 10s)
  - User contact information collection
  - Optional description for custom requirements
  - Success screen with confirmation
- **Processing**: Admin team processes requests manually and sends results via email

## External Dependencies

### AI Service Providers
- **ClipDrop API**: Primary service for background removal, object cleanup, text removal, image upscaling, and professional image enhancement
- **Hugging Face Inference API**: Text-to-image generation using Stable Diffusion models and AnimateDiff for image-to-video conversion
- **Segmind API**: LTX Video model for real-time video generation from images
- **Real-ESRGAN**: Image super-resolution and quality enhancement
- **Admin Processing System**: Manual video processing by admin team for AI video creation

### Core Flutter Dependencies
- **HTTP & Networking**: `dio` for API requests, `http` for basic HTTP operations
- **State Management**: `provider` package for reactive state management
- **Media Handling**: `image_picker` for camera/gallery access, `video_player` for video playback
- **Image Processing**: `image` package for local image manipulation and format conversion
- **File System**: `path_provider` for file storage, `share_plus` for sharing functionality
- **Audio**: `audioplayers` for background music and sound effects
- **UI Components**: `phosphor_flutter` for modern icon sets
- **Image Caching**: `cached_network_image` for efficient banner image loading

### Platform Integrations
- **OneSignal**: Push notification service with Firebase Cloud Messaging backend
- **Android Platform**: Native Android integration with proper permissions and manifest configuration
- **File System**: Local storage for temporary files and processed images

### Development and Build Tools
- **GitHub Actions**: Automated CI/CD pipeline for APK building and release management
- **Gradle Build System**: Android build configuration with multi-API key support
- **Flutter Build Tools**: Release APK generation with optimization flags

### Database and Storage
- **SharedPreferences**: Local key-value storage for user settings and API configurations
- **Temporary File System**: Local file caching for image processing workflows
- **Asset Management**: Video assets for feature demonstrations and UI enhancement

## Project Structure

```
ai_image_editor_flutter/
├── lib/
│   ├── models/
│   │   ├── event_banner.dart      # Banner data model
│   │   └── video_job.dart         # Video creation job model
│   ├── widgets/
│   │   └── event_banner_slider.dart # Banner slider widget
│   ├── screens/
│   │   ├── main_screen.dart       # Main app screen with banner integration
│   │   └── ai_video_creation_screen.dart # AI video creation form
│   └── ...
└── pubspec.yaml                   # Updated with new dependencies
```

## Git and Build Guidelines

- Always include manual git push commands when making code changes
- Ensure changes don't affect APK build process compatibility
- Follow semantic versioning for releases
- Test build process after major changes