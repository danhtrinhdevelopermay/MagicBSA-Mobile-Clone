// Test script to verify mobile app integration with backend
const http = require('http');
const FormData = require('form-data');
const fs = require('fs');

const BASE_URL = 'http://localhost:5000/api';

// Test functions
async function testHealthCheck() {
  return new Promise((resolve, reject) => {
    http.get(`${BASE_URL}/health`, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          console.log('✅ Health Check:', result.status === 'ok' ? 'PASSED' : 'FAILED');
          resolve(result.status === 'ok');
        } catch (e) {
          console.log('❌ Health Check: FAILED -', e.message);
          resolve(false);
        }
      });
    }).on('error', (e) => {
      console.log('❌ Health Check: FAILED -', e.message);
      resolve(false);
    });
  });
}

async function testEventBanners() {
  return new Promise((resolve, reject) => {
    http.get(`${BASE_URL}/event-banners`, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          console.log('✅ Event Banners:', result.success === true ? 'PASSED' : 'FAILED');
          console.log('   Response format:', JSON.stringify(result, null, 2));
          resolve(result.success === true);
        } catch (e) {
          console.log('❌ Event Banners: FAILED -', e.message);
          resolve(false);
        }
      });
    }).on('error', (e) => {
      console.log('❌ Event Banners: FAILED -', e.message);
      resolve(false);
    });
  });
}

async function testVideoJobSubmission() {
  return new Promise((resolve, reject) => {
    // Create a simple test image (1x1 pixel PNG)
    const testImageBuffer = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==', 'base64');
    
    const form = new FormData();
    form.append('userEmail', 'test@example.com');
    form.append('userName', 'Test User');
    form.append('userPhone', '0123456789');
    form.append('videoStyle', 'cinematic');
    form.append('videoDuration', '5');
    form.append('description', 'Test video job from integration test');
    form.append('image', testImageBuffer, {
      filename: 'test-image.png',
      contentType: 'image/png'
    });

    const options = {
      hostname: 'localhost',
      port: 5000,
      path: '/api/video-jobs',
      method: 'POST',
      headers: form.getHeaders()
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          console.log('✅ Video Job Submission:', result.success === true ? 'PASSED' : 'FAILED');
          console.log('   Response:', JSON.stringify(result, null, 2));
          resolve(result.success === true);
        } catch (e) {
          console.log('❌ Video Job Submission: FAILED -', e.message);
          console.log('   Raw response:', data);
          resolve(false);
        }
      });
    });

    req.on('error', (e) => {
      console.log('❌ Video Job Submission: FAILED -', e.message);
      resolve(false);
    });

    form.pipe(req);
  });
}

// Run all tests
async function runIntegrationTests() {
  console.log('🚀 Starting Mobile App Backend Integration Tests\n');
  
  const tests = [
    { name: 'Health Check', fn: testHealthCheck },
    { name: 'Event Banners API', fn: testEventBanners },
    { name: 'Video Job Submission', fn: testVideoJobSubmission }
  ];

  const results = [];
  
  for (const test of tests) {
    console.log(`Testing ${test.name}...`);
    const result = await test.fn();
    results.push({ name: test.name, passed: result });
    console.log('');
  }

  console.log('📊 Test Results Summary:');
  console.log('========================');
  
  const passed = results.filter(r => r.passed).length;
  const total = results.length;
  
  results.forEach(result => {
    console.log(`${result.passed ? '✅' : '❌'} ${result.name}`);
  });
  
  console.log(`\n🎯 Overall: ${passed}/${total} tests passed`);
  
  if (passed === total) {
    console.log('🎉 All integration tests PASSED! Mobile app is ready to connect to backend.');
  } else {
    console.log('⚠️  Some tests failed. Please check the backend configuration.');
  }
}

// Run tests if this file is executed directly
if (require.main === module) {
  runIntegrationTests().catch(console.error);
}

module.exports = { runIntegrationTests };