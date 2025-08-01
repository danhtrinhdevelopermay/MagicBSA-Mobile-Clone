const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// API Keys Configuration File
const CONFIG_FILE = path.join(__dirname, 'config.json');

// Default configuration
const DEFAULT_CONFIG = {
  clipdrop: {
    primary: '2f62a50ae0c0b965c1f54763e90bb44c101d8d1b84b5a670f4a6bd336954ec2c77f3c3b28ad0c1c9271fcfdfa2abc664',
    backup: '7ce6a169f98dc2fb224fc5ad1663c53716b1ee3332fc7a3903dc8a5092feb096731cf4a19f9989cb2901351e1c086ff2',
    status: 'active',
    lastUpdated: new Date().toISOString()
  }
};

// Read configuration from file
function readConfig() {
  try {
    if (fs.existsSync(CONFIG_FILE)) {
      const data = fs.readFileSync(CONFIG_FILE, 'utf8');
      return JSON.parse(data);
    }
    return DEFAULT_CONFIG;
  } catch (error) {
    console.error('Error reading config:', error);
    return DEFAULT_CONFIG;
  }
}

// Write configuration to file
function writeConfig(config) {
  try {
    fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2));
    return true;
  } catch (error) {
    console.error('Error writing config:', error);
    return false;
  }
}

// Initialize config file if it doesn't exist
if (!fs.existsSync(CONFIG_FILE)) {
  writeConfig(DEFAULT_CONFIG);
}

// API Routes

// Get API keys (for Flutter app)
app.get('/api/config/clipdrop-keys', (req, res) => {
  try {
    const config = readConfig();
    res.json({
      primary: config.clipdrop.primary,
      backup: config.clipdrop.backup,
      status: config.clipdrop.status,
      lastUpdated: config.clipdrop.lastUpdated
    });
    console.log('✅ API keys requested by Flutter app');
  } catch (error) {
    console.error('Error getting API keys:', error);
    res.status(500).json({ error: 'Failed to get API keys' });
  }
});

// Update API keys (for web interface)
app.post('/api/config/clipdrop-keys', (req, res) => {
  try {
    const { primary, backup, status } = req.body;
    
    if (!primary || !backup) {
      return res.status(400).json({ error: 'Both primary and backup API keys are required' });
    }

    const config = readConfig();
    config.clipdrop = {
      primary,
      backup,
      status: status || 'active',
      lastUpdated: new Date().toISOString()
    };

    if (writeConfig(config)) {
      res.json({
        message: 'API keys updated successfully',
        config: config.clipdrop
      });
      console.log('✅ API keys updated successfully');
    } else {
      res.status(500).json({ error: 'Failed to save configuration' });
    }
  } catch (error) {
    console.error('Error updating API keys:', error);
    res.status(500).json({ error: 'Failed to update API keys' });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Root endpoint
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 ClipDrop API Key Server running on port ${PORT}`);
  console.log(`📋 API Endpoint: http://localhost:${PORT}/api/config/clipdrop-keys`);
  console.log(`🌐 Web Interface: http://localhost:${PORT}`);
});