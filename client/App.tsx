import React from 'react';

function App() {
  return (
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h1>🎬 Twink Video Backend Admin Panel</h1>
      <p>Web backend API đang chạy thành công!</p>
      
      <div style={{ marginTop: '20px' }}>
        <h2>📋 API Endpoints:</h2>
        <ul>
          <li><strong>Health Check:</strong> <code>GET /api/health</code></li>
          <li><strong>Submit Video Job:</strong> <code>POST /api/video-jobs</code></li>
          <li><strong>Get Video Job:</strong> <code>GET /api/video-jobs/:id</code></li>
          <li><strong>Get Event Banners:</strong> <code>GET /api/event-banners</code></li>
          <li><strong>Admin - All Video Jobs:</strong> <code>GET /api/admin/video-jobs</code></li>
          <li><strong>Admin - Update Job:</strong> <code>PATCH /api/admin/video-jobs/:id</code></li>
        </ul>
      </div>
      
      <div style={{ marginTop: '20px' }}>
        <h2>📱 Tích hợp với Mobile App:</h2>
        <p>Mobile app có thể gửi yêu cầu tạo video đến endpoint này.</p>
        <p>Admin sẽ nhận email thông báo và có thể cập nhật trạng thái qua API.</p>
      </div>
    </div>
  );
}

export default App;