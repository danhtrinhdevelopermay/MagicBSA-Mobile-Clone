import { videoJobs, eventBanners, type VideoJob, type EventBanner, type InsertVideoJob, type InsertEventBanner, type UpdateVideoJob } from "../shared/schema.js";
import { db } from "./db.js";
import { eq, desc } from "drizzle-orm";

export interface IStorage {
  // Video job operations
  createVideoJob(job: InsertVideoJob): Promise<VideoJob>;
  getVideoJob(id: string): Promise<VideoJob | undefined>;
  getAllVideoJobs(): Promise<VideoJob[]>;
  updateVideoJob(id: string, updates: UpdateVideoJob): Promise<VideoJob | undefined>;
  deleteVideoJob(id: string): Promise<boolean>;
  
  // Event banner operations
  getAllEventBanners(): Promise<EventBanner[]>;
  getActiveEventBanners(): Promise<EventBanner[]>;
  createEventBanner(banner: InsertEventBanner): Promise<EventBanner>;
  updateEventBanner(id: string, updates: Partial<InsertEventBanner>): Promise<EventBanner | undefined>;
  deleteEventBanner(id: string): Promise<boolean>;
}

export class DatabaseStorage implements IStorage {
  // Video job operations
  async createVideoJob(jobData: InsertVideoJob): Promise<VideoJob> {
    const [job] = await db
      .insert(videoJobs)
      .values(jobData)
      .returning();
    return job;
  }

  async getVideoJob(id: string): Promise<VideoJob | undefined> {
    const [job] = await db
      .select()
      .from(videoJobs)
      .where(eq(videoJobs.id, id));
    return job;
  }

  async getAllVideoJobs(): Promise<VideoJob[]> {
    return await db
      .select()
      .from(videoJobs)
      .orderBy(desc(videoJobs.createdAt));
  }

  async updateVideoJob(id: string, updates: UpdateVideoJob): Promise<VideoJob | undefined> {
    const updateData: any = {
      ...updates,
      updatedAt: new Date(),
    };
    
    if (updates.status === 'completed') {
      updateData.completedAt = new Date();
    }
    
    const [updatedJob] = await db
      .update(videoJobs)
      .set(updateData)
      .where(eq(videoJobs.id, id))
      .returning();
    return updatedJob;
  }

  async deleteVideoJob(id: string): Promise<boolean> {
    const result = await db
      .delete(videoJobs)
      .where(eq(videoJobs.id, id));
    return (result.rowCount ?? 0) > 0;
  }

  // Event banner operations
  async getAllEventBanners(): Promise<EventBanner[]> {
    return await db
      .select()
      .from(eventBanners)
      .orderBy(desc(eventBanners.priority), desc(eventBanners.createdAt));
  }

  async getActiveEventBanners(): Promise<EventBanner[]> {
    return await db
      .select()
      .from(eventBanners)
      .where(eq(eventBanners.isActive, true))
      .orderBy(desc(eventBanners.priority), desc(eventBanners.createdAt));
  }

  async createEventBanner(bannerData: InsertEventBanner): Promise<EventBanner> {
    const [banner] = await db
      .insert(eventBanners)
      .values(bannerData)
      .returning();
    return banner;
  }

  async updateEventBanner(id: string, updates: Partial<InsertEventBanner>): Promise<EventBanner | undefined> {
    const [updatedBanner] = await db
      .update(eventBanners)
      .set({
        ...updates,
        updatedAt: new Date(),
      })
      .where(eq(eventBanners.id, id))
      .returning();
    return updatedBanner;
  }

  async deleteEventBanner(id: string): Promise<boolean> {
    const result = await db
      .delete(eventBanners)
      .where(eq(eventBanners.id, id));
    return (result.rowCount ?? 0) > 0;
  }
}

export const storage = new DatabaseStorage();