# AI Image Editor

## Overview
This project provides AI-powered image editing, specifically background and object removal, via a React web application and a Flutter mobile app. Both platforms integrate with the Clipdrop API for AI processing. The aim is to deliver intuitive and efficient image manipulation tools to users through a web interface and an Android APK. The project envisions widespread adoption due to its user-friendly interface and powerful AI capabilities, offering a compelling solution for quick and professional image edits.

## User Preferences
Preferred communication style: Simple, everyday language.
Always provide manual Git push commands from root directory when making changes to the codebase.
Minimize code changes that could break GitHub Actions APK build process.
Focus on practical, working solutions.

## System Architecture

### Web Application
The web application features a React 18 frontend with TypeScript, Wouter for routing, TanStack Query for state management, and Tailwind CSS with shadcn/ui for UI. The backend uses Node.js and Express.js, handling file uploads with Multer. Database operations are managed via Drizzle ORM with PostgreSQL (configured for Neon serverless).

### Flutter Mobile Application
The mobile application is developed using Flutter 3.22.0 and Dart, employing the Provider pattern for state management and Material 3 for UI design. It's configured for Android APK builds with GitHub Actions support.

#### Core Features & Design Patterns:
- **Feature-First Flow**: User flow prioritizes feature selection (e.g., Remove Background, Cleanup) before image upload, using icon-based feature cards with gradient backgrounds.
- **Precision Mask Drawing**: Implemented for object removal, featuring pixel-perfect mask creation via bitmap manipulation for accuracy and real-time visual feedback.
- **Auto-Scroll to Results**: After AI processing, the EditorScreen automatically scrolls to display results.
- **Enhanced UI/UX**: Both web and mobile applications incorporate modern design elements like glassmorphism effects, gradient themes, advanced animations (e.g., floating bottom navigation with elastic animations), and intuitive controls.
- **Comprehensive History System**: Saves processed images locally (with optional cloud sync), allowing users to view, download, share, and delete past edits.
- **API Auto-Resize**: All Clipdrop API integrations include automatic image resizing to comply with API limits while preserving aspect ratio.
- **Coordinate Mapping**: Accurate coordinate mapping for mask drawing ensures user input precisely matches AI processing areas.
- **Loading Overlay**: A full-screen, blurred loading overlay with animated elements enhances user experience during AI processing.
- **System UI Transparency**: Designed for an edge-to-edge immersive experience with transparent system bars.
- **Advanced Brush System**: Enhanced controls for mask drawing include undo/redo, eraser mode, brush opacity, and size adjustment.
- **Interactive Viewer**: Zoom/pan functionality for precise mask drawing.
- **Floating Controls**: Professional glassmorphism control panel with slide-up animation and modern button design.
- **Haptic Feedback**: Added tactile responses for all user interactions.
- **Processing Overlay**: Sophisticated backdrop blur overlay with animated elements.
- **Dynamic API Key Management**: API keys are fetched dynamically from a separate server, with local caching and fallback mechanisms.

## External Dependencies

### Web Application
- **Clipdrop API**: For all AI image processing (background removal, object cleanup, uncrop, reimagine, text-to-image, product photography, image upscaling).
- **@neondatabase/serverless**: PostgreSQL serverless connection.
- **@tanstack/react-query**: Server state management.
- **drizzle-orm**: Type-safe ORM.
- **multer**: File upload handling.

### Flutter Mobile Application
- **Clipdrop API**: Integrated for all AI image processing functionalities.
- **Segmind API**: Advanced integration for AI image-to-video generation using LTX Video model.
- **Firebase**: For OneSignal push notification integration.
- **OneSignal**: Push notification service.
- **audioplayers**: For background music and sound effects.
- **image_picker, image**: For image file operations.
- **dio, http**: For HTTP requests to Clipdrop and Segmind APIs.
- **path_provider, share_plus**: For local storage and sharing.
- **permission_handler**: For Android permissions.
- **curved_navigation_bar**: For advanced bottom navigation UI.
- **video_player**: For video playback of generated content.