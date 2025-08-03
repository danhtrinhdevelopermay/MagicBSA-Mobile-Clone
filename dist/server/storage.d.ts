import { type VideoJob, type EventBanner, type InsertVideoJob, type InsertEventBanner, type UpdateVideoJob } from "../shared/schema.js";
export interface IStorage {
    createVideoJob(job: InsertVideoJob): Promise<VideoJob>;
    getVideoJob(id: string): Promise<VideoJob | undefined>;
    getAllVideoJobs(): Promise<VideoJob[]>;
    updateVideoJob(id: string, updates: UpdateVideoJob): Promise<VideoJob | undefined>;
    deleteVideoJob(id: string): Promise<boolean>;
    getAllEventBanners(): Promise<EventBanner[]>;
    getActiveEventBanners(): Promise<EventBanner[]>;
    createEventBanner(banner: InsertEventBanner): Promise<EventBanner>;
    updateEventBanner(id: string, updates: Partial<InsertEventBanner>): Promise<EventBanner | undefined>;
    deleteEventBanner(id: string): Promise<boolean>;
}
export declare class DatabaseStorage implements IStorage {
    createVideoJob(jobData: InsertVideoJob): Promise<VideoJob>;
    getVideoJob(id: string): Promise<VideoJob | undefined>;
    getAllVideoJobs(): Promise<VideoJob[]>;
    updateVideoJob(id: string, updates: UpdateVideoJob): Promise<VideoJob | undefined>;
    deleteVideoJob(id: string): Promise<boolean>;
    getAllEventBanners(): Promise<EventBanner[]>;
    getActiveEventBanners(): Promise<EventBanner[]>;
    createEventBanner(bannerData: InsertEventBanner): Promise<EventBanner>;
    updateEventBanner(id: string, updates: Partial<InsertEventBanner>): Promise<EventBanner | undefined>;
    deleteEventBanner(id: string): Promise<boolean>;
}
export declare const storage: DatabaseStorage;
//# sourceMappingURL=storage.d.ts.map