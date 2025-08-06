import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import session from 'express-session';
import connectPg from 'connect-pg-simple';
import { registerRoutes } from './routes.js';

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  contentSecurityPolicy: {
    directives: {
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
}));

// Enable CORS for mobile app
app.use(cors({
  origin: [
    'http://localhost:3000',
    'https://twink.ai',
    // Add your mobile app domains here
  ],
  credentials: true,
}));

// Compression and parsing middleware
app.use(compression());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Session configuration for admin panel
const sessionTtl = 7 * 24 * 60 * 60 * 1000; // 1 week
const pgStore = connectPg(session);
const sessionStore = new pgStore({
  conString: process.env.DATABASE_URL,
  createTableIfMissing: false,
  ttl: sessionTtl,
  tableName: "sessions",
});

app.use(session({
  secret: process.env.SESSION_SECRET || 'default-session-secret-change-in-production',
  store: sessionStore,
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    maxAge: sessionTtl,
  },
}));

// Trust proxy for proper IP detection
app.set('trust proxy', 1);

// Start the application
async function startServer() {
  // Register API routes
  const server = await registerRoutes(app);

  // Error handling middleware
  app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
    console.error('Server error:', err);
    
    res.status(500).json({
      success: false,
      message: process.env.NODE_ENV === 'production' 
        ? 'Lỗi server' 
        : err.message
    });
  });

  // 404 handler
  app.use((req, res) => {
    res.status(404).json({
      success: false,
      message: 'API endpoint không tồn tại'
    });
  });

  // Start server
  server.listen(Number(PORT), '0.0.0.0', () => {
    console.log(`🚀 Twink Video Backend API running on port ${PORT}`);
    console.log(`📍 Health check: http://localhost:${PORT}/api/health`);
    console.log(`🎬 Video jobs: http://localhost:${PORT}/api/video-jobs`);
    console.log(`📱 Event banners: http://localhost:${PORT}/api/event-banners`);
  });

  // Graceful shutdown
  process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully');
    server.close(() => {
      console.log('Process terminated');
    });
  });
}

// Start the server
startServer().catch(console.error);