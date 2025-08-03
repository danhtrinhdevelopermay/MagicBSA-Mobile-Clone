import { sql } from "drizzle-orm";
import { pgTable, text, varchar, timestamp, json, boolean } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";

export const imageJobs = pgTable("image_jobs", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  originalImageUrl: text("original_image_url").notNull(),
  processedImageUrl: text("processed_image_url"),
  operation: text("operation", { enum: ["remove_background", "remove_text", "cleanup", "remove_logo"] }).notNull(),
  status: text("status", { enum: ["pending", "processing", "completed", "failed"] }).notNull().default("pending"),
  errorMessage: text("error_message"),
  metadata: json("metadata"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const videoJobs = pgTable("video_jobs", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  userEmail: text("user_email").notNull(),
  userName: text("user_name").notNull(),
  phoneNumber: text("phone_number"),
  originalImageUrl: text("original_image_url").notNull(),
  videoStyle: text("video_style").notNull(),
  duration: text("duration").notNull(),
  description: text("description"),
  resultVideoUrl: text("result_video_url"),
  status: text("status", { enum: ["pending", "processing", "completed", "failed"] }).notNull().default("pending"),
  adminNotes: text("admin_notes"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const eventBanners = pgTable("event_banners", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  title: text("title").notNull(),
  description: text("description").notNull(),
  imageUrl: text("image_url").notNull(),
  actionUrl: text("action_url").notNull(),
  isActive: boolean("is_active").notNull().default(true),
  order: varchar("order").notNull().default("0"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertImageJobSchema = createInsertSchema(imageJobs).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

export const insertVideoJobSchema = createInsertSchema(videoJobs).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

export const insertEventBannerSchema = createInsertSchema(eventBanners).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

export type InsertImageJob = z.infer<typeof insertImageJobSchema>;
export type ImageJob = typeof imageJobs.$inferSelect;
export type InsertVideoJob = z.infer<typeof insertVideoJobSchema>;
export type VideoJob = typeof videoJobs.$inferSelect;
export type InsertEventBanner = z.infer<typeof insertEventBannerSchema>;
export type EventBanner = typeof eventBanners.$inferSelect;
