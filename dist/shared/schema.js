import { sql } from 'drizzle-orm';
import { index, jsonb, pgTable, timestamp, varchar, text, integer, boolean, } from "drizzle-orm/pg-core";
import { z } from "zod";
// Session storage table for authentication
export const sessions = pgTable("sessions", {
    sid: varchar("sid").primaryKey(),
    sess: jsonb("sess").notNull(),
    expire: timestamp("expire").notNull(),
}, (table) => [index("IDX_session_expire").on(table.expire)]);
// Video creation jobs table
export const videoJobs = pgTable("video_jobs", {
    id: varchar("id").primaryKey().default(sql `gen_random_uuid()`),
    userName: varchar("user_name", { length: 100 }).notNull(),
    userEmail: varchar("user_email", { length: 255 }).notNull(),
    userPhone: varchar("user_phone", { length: 20 }),
    // Video configuration
    videoStyle: varchar("video_style", {
        enum: ["cinematic", "anime", "realistic", "artistic", "vintage", "futuristic"]
    }).notNull(),
    videoDuration: integer("video_duration").notNull(), // in seconds: 3, 5, 10
    // Image data
    imageUrl: text("image_url").notNull(),
    imageFileName: varchar("image_file_name", { length: 255 }).notNull(),
    // Optional description
    description: text("description"),
    // Processing status
    status: varchar("status", {
        enum: ["pending", "processing", "completed", "failed"]
    }).notNull().default("pending"),
    // Admin processing
    adminNotes: text("admin_notes"),
    processedVideoUrl: text("processed_video_url"),
    // Timestamps
    createdAt: timestamp("created_at").defaultNow(),
    updatedAt: timestamp("updated_at").defaultNow(),
    completedAt: timestamp("completed_at"),
});
// Event banners table for mobile app
export const eventBanners = pgTable("event_banners", {
    id: varchar("id").primaryKey().default(sql `gen_random_uuid()`),
    title: varchar("title", { length: 200 }).notNull(),
    description: text("description"),
    imageUrl: text("image_url").notNull(),
    actionUrl: varchar("action_url", { length: 500 }),
    actionText: varchar("action_text", { length: 100 }),
    isActive: boolean("is_active").notNull().default(true),
    priority: integer("priority").notNull().default(0), // Higher priority shows first
    createdAt: timestamp("created_at").defaultNow(),
    updatedAt: timestamp("updated_at").defaultNow(),
});
// Insert schemas with validation
export const insertVideoJobSchema = z.object({
    userName: z.string().min(1, "Tên người dùng là bắt buộc").max(100),
    userEmail: z.string().email("Email không hợp lệ").max(255),
    userPhone: z.string().max(20).optional(),
    videoStyle: z.enum(["cinematic", "anime", "realistic", "artistic", "vintage", "futuristic"]),
    videoDuration: z.number().int().min(3).max(10),
    imageUrl: z.string().min(1, "URL ảnh là bắt buộc"),
    imageFileName: z.string().min(1).max(255),
    description: z.string().max(1000).optional(),
});
export const insertEventBannerSchema = z.object({
    title: z.string().min(1, "Tiêu đề là bắt buộc").max(200),
    description: z.string().max(1000).optional(),
    imageUrl: z.string().min(1, "URL ảnh là bắt buộc"),
    actionUrl: z.string().max(500).optional(),
    actionText: z.string().max(100).optional(),
    priority: z.number().int().min(0).max(100).default(0),
});
// Update schemas
export const updateVideoJobSchema = z.object({
    status: z.enum(["pending", "processing", "completed", "failed"]).optional(),
    adminNotes: z.string().optional(),
    processedVideoUrl: z.string().optional(),
}).partial();
//# sourceMappingURL=schema.js.map