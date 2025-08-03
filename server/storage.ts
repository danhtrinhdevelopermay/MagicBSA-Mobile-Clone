import { type ImageJob, type InsertImageJob, type VideoJob, type InsertVideoJob, type EventBanner, type InsertEventBanner } from "@shared/schema";
import { randomUUID } from "crypto";

export interface IStorage {
  // Image jobs
  createImageJob(job: InsertImageJob): Promise<ImageJob>;
  getImageJob(id: string): Promise<ImageJob | undefined>;
  updateImageJob(id: string, updates: Partial<ImageJob>): Promise<ImageJob | undefined>;
  getAllImageJobs(): Promise<ImageJob[]>;
  
  // Video jobs
  createVideoJob(job: InsertVideoJob): Promise<VideoJob>;
  getVideoJob(id: string): Promise<VideoJob | undefined>;
  updateVideoJob(id: string, updates: Partial<VideoJob>): Promise<VideoJob | undefined>;
  getAllVideoJobs(): Promise<VideoJob[]>;
  
  // Event banners
  createEventBanner(banner: InsertEventBanner): Promise<EventBanner>;
  getEventBanner(id: string): Promise<EventBanner | undefined>;
  updateEventBanner(id: string, updates: Partial<EventBanner>): Promise<EventBanner | undefined>;
  getAllEventBanners(): Promise<EventBanner[]>;
  getActiveEventBanners(): Promise<EventBanner[]>;
  deleteEventBanner(id: string): Promise<boolean>;
}

export class MemStorage implements IStorage {
  private imageJobs: Map<string, ImageJob>;
  private videoJobs: Map<string, VideoJob>;
  private eventBanners: Map<string, EventBanner>;

  constructor() {
    this.imageJobs = new Map();
    this.videoJobs = new Map();
    this.eventBanners = new Map();
  }

  async createImageJob(insertJob: InsertImageJob): Promise<ImageJob> {
    const id = randomUUID();
    const now = new Date();
    const job: ImageJob = { 
      id, 
      originalImageUrl: insertJob.originalImageUrl,
      processedImageUrl: insertJob.processedImageUrl || null,
      operation: insertJob.operation,
      status: insertJob.status || "pending",
      errorMessage: insertJob.errorMessage || null,
      metadata: insertJob.metadata || null,
      createdAt: now,
      updatedAt: now
    };
    this.imageJobs.set(id, job);
    return job;
  }

  async getImageJob(id: string): Promise<ImageJob | undefined> {
    return this.imageJobs.get(id);
  }

  async updateImageJob(id: string, updates: Partial<ImageJob>): Promise<ImageJob | undefined> {
    const existingJob = this.imageJobs.get(id);
    if (!existingJob) return undefined;
    
    const updatedJob: ImageJob = {
      ...existingJob,
      ...updates,
      updatedAt: new Date()
    };
    
    this.imageJobs.set(id, updatedJob);
    return updatedJob;
  }

  async getAllImageJobs(): Promise<ImageJob[]> {
    return Array.from(this.imageJobs.values()).sort(
      (a, b) => b.createdAt.getTime() - a.createdAt.getTime()
    );
  }

  // Video jobs implementation
  async createVideoJob(insertJob: InsertVideoJob): Promise<VideoJob> {
    const id = randomUUID();
    const now = new Date();
    const job: VideoJob = { 
      id, 
      userEmail: insertJob.userEmail,
      userName: insertJob.userName,
      phoneNumber: insertJob.phoneNumber || null,
      originalImageUrl: insertJob.originalImageUrl,
      videoStyle: insertJob.videoStyle,
      duration: insertJob.duration,
      description: insertJob.description || null,
      resultVideoUrl: insertJob.resultVideoUrl || null,
      status: insertJob.status || "pending",
      adminNotes: insertJob.adminNotes || null,
      createdAt: now,
      updatedAt: now
    };
    this.videoJobs.set(id, job);
    return job;
  }

  async getVideoJob(id: string): Promise<VideoJob | undefined> {
    return this.videoJobs.get(id);
  }

  async updateVideoJob(id: string, updates: Partial<VideoJob>): Promise<VideoJob | undefined> {
    const existingJob = this.videoJobs.get(id);
    if (!existingJob) return undefined;
    
    const updatedJob: VideoJob = {
      ...existingJob,
      ...updates,
      updatedAt: new Date()
    };
    
    this.videoJobs.set(id, updatedJob);
    return updatedJob;
  }

  async getAllVideoJobs(): Promise<VideoJob[]> {
    return Array.from(this.videoJobs.values()).sort(
      (a, b) => b.createdAt.getTime() - a.createdAt.getTime()
    );
  }

  // Event banners implementation
  async createEventBanner(insertBanner: InsertEventBanner): Promise<EventBanner> {
    const id = randomUUID();
    const now = new Date();
    const banner: EventBanner = { 
      id, 
      title: insertBanner.title,
      description: insertBanner.description,
      imageUrl: insertBanner.imageUrl,
      actionUrl: insertBanner.actionUrl,
      isActive: insertBanner.isActive ?? true,
      order: insertBanner.order || "0",
      createdAt: now,
      updatedAt: now
    };
    this.eventBanners.set(id, banner);
    return banner;
  }

  async getEventBanner(id: string): Promise<EventBanner | undefined> {
    return this.eventBanners.get(id);
  }

  async updateEventBanner(id: string, updates: Partial<EventBanner>): Promise<EventBanner | undefined> {
    const existingBanner = this.eventBanners.get(id);
    if (!existingBanner) return undefined;
    
    const updatedBanner: EventBanner = {
      ...existingBanner,
      ...updates,
      updatedAt: new Date()
    };
    
    this.eventBanners.set(id, updatedBanner);
    return updatedBanner;
  }

  async getAllEventBanners(): Promise<EventBanner[]> {
    return Array.from(this.eventBanners.values()).sort(
      (a, b) => parseInt(a.order) - parseInt(b.order)
    );
  }

  async getActiveEventBanners(): Promise<EventBanner[]> {
    return Array.from(this.eventBanners.values())
      .filter(banner => banner.isActive)
      .sort((a, b) => parseInt(a.order) - parseInt(b.order));
  }

  async deleteEventBanner(id: string): Promise<boolean> {
    return this.eventBanners.delete(id);
  }
}

export const storage = new MemStorage();
