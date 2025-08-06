import { MailService } from '@sendgrid/mail';
import type { VideoJob } from '../shared/schema.js';

if (!process.env.SENDGRID_API_KEY) {
  console.warn("SENDGRID_API_KEY not found. Email notifications will be skipped.");
}

const mailService = new MailService();
if (process.env.SENDGRID_API_KEY) {
  mailService.setApiKey(process.env.SENDGRID_API_KEY);
}

const ADMIN_EMAIL = process.env.ADMIN_EMAIL || 'admin@twink.ai';
const FROM_EMAIL = process.env.FROM_EMAIL || 'noreply@twink.ai';

export async function sendVideoJobNotification(videoJob: VideoJob): Promise<boolean> {
  if (!process.env.SENDGRID_API_KEY) {
    console.log('SendGrid not configured, skipping email notification');
    return false;
  }

  try {
    const emailData = {
      to: ADMIN_EMAIL,
      from: FROM_EMAIL,
      subject: `🎬 Yêu cầu tạo video mới - ${videoJob.userName}`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px;">
            🎬 Yêu cầu tạo video AI từ ảnh
          </h2>
          
          <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <h3 style="color: #007bff; margin-top: 0;">Thông tin người dùng</h3>
            <p><strong>Tên:</strong> ${videoJob.userName}</p>
            <p><strong>Email:</strong> ${videoJob.userEmail}</p>
            ${videoJob.userPhone ? `<p><strong>Số điện thoại:</strong> ${videoJob.userPhone}</p>` : ''}
          </div>
          
          <div style="background: #fff3cd; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <h3 style="color: #856404; margin-top: 0;">Cấu hình video</h3>
            <p><strong>Phong cách:</strong> ${getStyleDisplayName(videoJob.videoStyle)}</p>
            <p><strong>Thời lượng:</strong> ${videoJob.videoDuration} giây</p>
            <p><strong>File ảnh:</strong> ${videoJob.imageFileName}</p>
            ${videoJob.description ? `<p><strong>Mô tả:</strong> ${videoJob.description}</p>` : ''}
          </div>
          
          <div style="background: #d1ecf1; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <h3 style="color: #0c5460; margin-top: 0;">Thông tin kỹ thuật</h3>
            <p><strong>Job ID:</strong> ${videoJob.id}</p>
            <p><strong>Thời gian tạo:</strong> ${videoJob.createdAt ? new Date(videoJob.createdAt).toLocaleString('vi-VN') : 'N/A'}</p>
            <p><strong>URL ảnh:</strong> <a href="${videoJob.imageUrl}">${videoJob.imageUrl}</a></p>
          </div>
          
          <div style="text-align: center; margin: 30px 0;">
            <a href="${process.env.ADMIN_PANEL_URL || 'http://localhost:3000'}/admin/video-jobs/${videoJob.id}" 
               style="background: #007bff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block;">
              Xử lý yêu cầu
            </a>
          </div>
          
          <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
          <p style="color: #666; font-size: 14px; text-align: center;">
            Email tự động từ hệ thống Twink AI Video Service
          </p>
        </div>
      `,
    };

    await mailService.send(emailData);
    console.log(`Video job notification sent to admin for job ${videoJob.id}`);
    return true;
    
  } catch (error) {
    console.error('Error sending video job notification:', error);
    return false;
  }
}

export async function sendVideoJobCompletionEmail(videoJob: VideoJob): Promise<boolean> {
  if (!process.env.SENDGRID_API_KEY) {
    console.log('SendGrid not configured, skipping completion email');
    return false;
  }

  try {
    const emailData = {
      to: videoJob.userEmail,
      from: FROM_EMAIL,
      subject: `🎉 Video AI của bạn đã hoàn thành - Twink AI`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #28a745; border-bottom: 2px solid #28a745; padding-bottom: 10px;">
            🎉 Video AI của bạn đã sẵn sàng!
          </h2>
          
          <p style="font-size: 16px; color: #333;">
            Xin chào <strong>${videoJob.userName}</strong>,
          </p>
          
          <p style="color: #333; line-height: 1.6;">
            Chúng tôi đã hoàn thành việc tạo video AI từ ảnh của bạn. Video được tạo với phong cách 
            <strong>${getStyleDisplayName(videoJob.videoStyle)}</strong> và thời lượng <strong>${videoJob.videoDuration} giây</strong>.
          </p>
          
          <div style="background: #d4edda; padding: 20px; border-radius: 8px; margin: 20px 0; text-align: center;">
            <h3 style="color: #155724; margin-top: 0;">📥 Tải video của bạn</h3>
            <a href="${videoJob.processedVideoUrl}" 
               style="background: #28a745; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 10px 0;">
              Tải xuống video
            </a>
            <p style="color: #155724; font-size: 14px; margin: 10px 0;">
              Link tải sẽ có hiệu lực trong 7 ngày
            </p>
          </div>
          
          ${videoJob.adminNotes ? `
            <div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px 0;">
              <h4 style="color: #333; margin-top: 0;">📝 Ghi chú từ đội ngũ xử lý:</h4>
              <p style="color: #666; font-style: italic;">${videoJob.adminNotes}</p>
            </div>
          ` : ''}
          
          <div style="background: #fff3cd; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <h4 style="color: #856404; margin-top: 0;">💡 Mẹo sử dụng</h4>
            <ul style="color: #856404; padding-left: 20px;">
              <li>Video đã được tối ưu cho việc chia sẻ trên mạng xã hội</li>
              <li>Bạn có thể sử dụng video này cho mục đích cá nhân và thương mại</li>
              <li>Nếu có vấn đề với video, vui lòng liên hệ với chúng tôi</li>
            </ul>
          </div>
          
          <div style="text-align: center; margin: 30px 0;">
            <p style="color: #333;">Cảm ơn bạn đã sử dụng dịch vụ Twink AI!</p>
            <a href="${process.env.APP_URL || 'https://twink.ai'}" 
               style="color: #007bff; text-decoration: none;">
              Quay lại ứng dụng
            </a>
          </div>
          
          <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
          <p style="color: #666; font-size: 12px; text-align: center;">
            Email tự động từ Twink AI - AI Image & Video Editor<br>
            Nếu bạn có thắc mắc, vui lòng liên hệ support@twink.ai
          </p>
        </div>
      `,
    };

    await mailService.send(emailData);
    console.log(`Video completion email sent to ${videoJob.userEmail} for job ${videoJob.id}`);
    return true;
    
  } catch (error) {
    console.error('Error sending video completion email:', error);
    return false;
  }
}

function getStyleDisplayName(style: string): string {
  const styleMap: Record<string, string> = {
    'cinematic': 'Điện ảnh',
    'anime': 'Anime',
    'realistic': 'Thực tế',
    'artistic': 'Nghệ thuật',
    'vintage': 'Cổ điển',
    'futuristic': 'Tương lai'
  };
  return styleMap[style] || style;
}