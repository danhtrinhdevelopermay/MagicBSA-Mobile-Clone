# AI Image Editor - Apple Photos Style Object Removal

## Project Overview
This is a full-stack JavaScript application that provides AI-powered image editing features, with a focus on object removal inspired by Apple Photos.

## Key Features
- **Apple Photos-inspired UI**: Clean, iOS-style interface for object removal
- **Interactive Mask Drawing**: Touch-friendly brush tool for selecting objects to remove
- **Real-time Processing**: Visual feedback during AI processing
- **Multiple AI Operations**: Background removal, text removal, cleanup, logo removal

## Project Architecture

### Frontend (React + Vite)
- **Main Components**:
  - `ApplePhotosEditor`: Full-screen iOS-style editor with mask drawing
  - `FileUploadTrigger`: Clean file upload component
  - Touch-optimized drawing canvas with pressure sensitivity
  
### Backend (Express + Node.js)
- **API Endpoints**:
  - `/api/cleanup`: Direct cleanup with mask processing
  - `/api/jobs`: Image job management
  - Clipdrop API integration for AI processing

### Database Schema
- `imageJobs` table for tracking processing jobs
- Support for various operations: cleanup, remove_background, remove_text, remove_logo

## Technical Implementation

### Apple Photos Editor Features
1. **Step 1 - Before Editing**:
   - Display original photo with editing tools
   - Bottom toolbar with Portrait, Live, Adjust, Filters, Crop, Clean Up
   - Touch-friendly interface

2. **Step 2 - While Processing**:
   - Semi-transparent overlay during AI processing
   - Pulsing blue effect on selected areas
   - Loading animation with progress feedback

3. **Step 3 - After Processing**:
   - Seamless object removal results
   - Undo/Redo functionality
   - Thumbs up/down feedback options

### Drawing System
- Canvas-based mask drawing with pointer events
- Pressure-sensitive brush strokes
- Real-time preview with smooth curves
- Scaling to match original image resolution

## User Preferences
- Theo yêu cầu trong loinhac.md: Khi có thay đổi code thì gửi kèm theo lệnh push git thủ công
- Đảm bảo không ảnh hưởng đến việc build APK khi thay đổi hoặc phát triển ứng dụng

## Recent Changes
- **2025-08-02**: Updated Flutter Android app with Apple Photos-style object removal interface
  - Removed brush size slider - fixed 24px size like Apple Photos
  - Changed mask color from red to white semi-transparent (matching iOS)
  - Added Apple Photos-style instruction overlay: "Tap, brush, or circle what you want to remove"
  - Updated header with Cancel/RESET/Clean Up buttons like iOS
  - Added processing overlay with "Cleaning up..." message
  - Full-screen interface without borders/margins
  - Instructions hide automatically after first draw

- **2025-08-01**: Created Apple Photos-inspired object removal interface (Web version)
  - Full-screen editor with iOS-style design
  - Interactive mask drawing with touch support
  - Real-time processing feedback
  - Integration with Clipdrop API for cleanup
  - Added file upload triggers and improved UX

## Routes
- `/` - Home page with feature overview
- `/apple-cleanup` - Apple Photos-style cleanup editor
- `/generation` - AI generation features
- `/upload` - File upload interface
- `/editor` - Original editor interface

## API Dependencies
- Clipdrop API for image processing
- Supports cleanup, background removal, text removal operations

## Development Notes
- Uses iOS-style blur effects and animations
- Touch-optimized for mobile devices
- Scalable vector graphics for clean icons
- Memory-efficient canvas operations