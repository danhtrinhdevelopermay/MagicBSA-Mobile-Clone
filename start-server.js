// Simple Node.js server starter for Twink Video Backend
const { spawn } = require('child_process');
const fs = require('fs');

console.log('🚀 Starting Twink Video Backend...');

// Check if required files exist
const requiredFiles = [
  'server/index.ts',
  'shared/schema.ts',
  'server/routes.ts',
  'server/storage.ts',
  'server/emailService.ts'
];

for (const file of requiredFiles) {
  if (!fs.existsSync(file)) {
    console.error(`❌ Required file missing: ${file}`);
    process.exit(1);
  }
}

console.log('✅ All required files found');
console.log('🔧 Starting TypeScript server...');

// Start the server
const server = spawn('tsx', ['server/index.ts'], {
  stdio: 'inherit',
  env: { ...process.env }
});

server.on('error', (err) => {
  console.error('❌ Failed to start server:', err);
});

server.on('close', (code) => {
  console.log(`🛑 Server process exited with code ${code}`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down server...');
  server.kill('SIGTERM');
  process.exit(0);
});

console.log('💡 Server starting... Check output above for API endpoints');
console.log('💡 Press Ctrl+C to stop the server');