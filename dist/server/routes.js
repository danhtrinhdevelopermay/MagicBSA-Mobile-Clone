import express from "express";
import { createServer } from "http";
import multer from "multer";
import path from "path";
import { storage } from "./storage.js";
import { insertVideoJobSchema, updateVideoJobSchema, insertEventBannerSchema } from "../shared/schema.js";
import { sendVideoJobNotification, sendVideoJobCompletionEmail } from "./emailService.js";
// Configure multer for image uploads
const upload = multer({
    dest: 'uploads/',
    limits: {
        fileSize: 10 * 1024 * 1024, // 10MB limit
    },
    fileFilter: (req, file, cb) => {
        const allowedTypes = /jpeg|jpg|png|webp/;
        const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
        const mimetype = allowedTypes.test(file.mimetype);
        if (mimetype && extname) {
            return cb(null, true);
        }
        else {
            cb(new Error('Chỉ chấp nhận file ảnh (JPEG, PNG, WebP)'));
        }
    }
});
export async function registerRoutes(app) {
    // Health check endpoint
    app.get('/api/health', (req, res) => {
        res.json({
            status: 'ok',
            message: 'Twink Video Backend API is running',
            timestamp: new Date().toISOString()
        });
    });
    // Video job endpoints
    // Submit new video creation request
    app.post('/api/video-jobs', upload.single('image'), async (req, res) => {
        try {
            if (!req.file) {
                return res.status(400).json({
                    success: false,
                    message: 'Vui lòng upload ảnh'
                });
            }
            // Parse and validate request data
            const jobData = {
                ...req.body,
                videoDuration: parseInt(req.body.videoDuration),
                imageUrl: `/uploads/${req.file.filename}`, // We'll serve uploads statically
                imageFileName: req.file.originalname,
            };
            const validatedData = insertVideoJobSchema.parse(jobData);
            // Create video job
            const videoJob = await storage.createVideoJob(validatedData);
            // Send notification email to admin
            await sendVideoJobNotification(videoJob);
            res.status(201).json({
                success: true,
                message: 'Yêu cầu tạo video đã được gửi thành công! Chúng tôi sẽ xử lý và gửi kết quả qua email trong 24-48h.',
                jobId: videoJob.id,
                data: videoJob
            });
        }
        catch (error) {
            console.error('Error creating video job:', error);
            if (error?.name === 'ZodError') {
                return res.status(400).json({
                    success: false,
                    message: 'Dữ liệu không hợp lệ',
                    errors: error.errors
                });
            }
            res.status(500).json({
                success: false,
                message: 'Lỗi server khi tạo yêu cầu video'
            });
        }
    });
    // Get video job status
    app.get('/api/video-jobs/:id', async (req, res) => {
        try {
            const { id } = req.params;
            const videoJob = await storage.getVideoJob(id);
            if (!videoJob) {
                return res.status(404).json({
                    success: false,
                    message: 'Không tìm thấy yêu cầu video'
                });
            }
            res.json({
                success: true,
                data: videoJob
            });
        }
        catch (error) {
            console.error('Error fetching video job:', error);
            res.status(500).json({
                success: false,
                message: 'Lỗi server khi lấy thông tin yêu cầu video'
            });
        }
    });
    // Admin: Get all video jobs
    app.get('/api/admin/video-jobs', async (req, res) => {
        try {
            const videoJobs = await storage.getAllVideoJobs();
            res.json({
                success: true,
                data: videoJobs,
                total: videoJobs.length
            });
        }
        catch (error) {
            console.error('Error fetching all video jobs:', error);
            res.status(500).json({
                success: false,
                message: 'Lỗi server khi lấy danh sách yêu cầu video'
            });
        }
    });
    // Admin: Update video job status
    app.patch('/api/admin/video-jobs/:id', async (req, res) => {
        try {
            const { id } = req.params;
            const updateData = updateVideoJobSchema.parse(req.body);
            const updatedJob = await storage.updateVideoJob(id, updateData);
            if (!updatedJob) {
                return res.status(404).json({
                    success: false,
                    message: 'Không tìm thấy yêu cầu video'
                });
            }
            // Send completion email if job is completed
            if (updateData.status === 'completed' && updateData.processedVideoUrl) {
                await sendVideoJobCompletionEmail(updatedJob);
            }
            res.json({
                success: true,
                message: 'Cập nhật yêu cầu video thành công',
                data: updatedJob
            });
        }
        catch (error) {
            console.error('Error updating video job:', error);
            if (error?.name === 'ZodError') {
                return res.status(400).json({
                    success: false,
                    message: 'Dữ liệu cập nhật không hợp lệ',
                    errors: error.errors
                });
            }
            res.status(500).json({
                success: false,
                message: 'Lỗi server khi cập nhật yêu cầu video'
            });
        }
    });
    // Event banner endpoints
    // Get active banners for mobile app
    app.get('/api/event-banners', async (req, res) => {
        try {
            const banners = await storage.getActiveEventBanners();
            res.json({
                success: true,
                data: banners
            });
        }
        catch (error) {
            console.error('Error fetching event banners:', error);
            res.status(500).json({
                success: false,
                message: 'Lỗi server khi lấy danh sách banner'
            });
        }
    });
    // Admin: Create new banner
    app.post('/api/admin/event-banners', async (req, res) => {
        try {
            const bannerData = insertEventBannerSchema.parse(req.body);
            const banner = await storage.createEventBanner(bannerData);
            res.status(201).json({
                success: true,
                message: 'Tạo banner thành công',
                data: banner
            });
        }
        catch (error) {
            console.error('Error creating banner:', error);
            if (error?.name === 'ZodError') {
                return res.status(400).json({
                    success: false,
                    message: 'Dữ liệu banner không hợp lệ',
                    errors: error.errors
                });
            }
            res.status(500).json({
                success: false,
                message: 'Lỗi server khi tạo banner'
            });
        }
    });
    // Admin: Get all banners
    app.get('/api/admin/event-banners', async (req, res) => {
        try {
            const banners = await storage.getAllEventBanners();
            res.json({
                success: true,
                data: banners
            });
        }
        catch (error) {
            console.error('Error fetching all banners:', error);
            res.status(500).json({
                success: false,
                message: 'Lỗi server khi lấy tất cả banner'
            });
        }
    });
    // Serve uploaded files
    app.use('/uploads', express.static('uploads'));
    const httpServer = createServer(app);
    return httpServer;
}
//# sourceMappingURL=routes.js.map