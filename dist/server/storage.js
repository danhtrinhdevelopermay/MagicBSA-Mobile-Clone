import { videoJobs, eventBanners } from "../shared/schema.js";
import { db } from "./db.js";
import { eq, desc } from "drizzle-orm";
export class DatabaseStorage {
    // Video job operations
    async createVideoJob(jobData) {
        const [job] = await db
            .insert(videoJobs)
            .values(jobData)
            .returning();
        return job;
    }
    async getVideoJob(id) {
        const [job] = await db
            .select()
            .from(videoJobs)
            .where(eq(videoJobs.id, id));
        return job;
    }
    async getAllVideoJobs() {
        return await db
            .select()
            .from(videoJobs)
            .orderBy(desc(videoJobs.createdAt));
    }
    async updateVideoJob(id, updates) {
        const updateData = {
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
    async deleteVideoJob(id) {
        const result = await db
            .delete(videoJobs)
            .where(eq(videoJobs.id, id));
        return (result.rowCount ?? 0) > 0;
    }
    // Event banner operations
    async getAllEventBanners() {
        return await db
            .select()
            .from(eventBanners)
            .orderBy(desc(eventBanners.priority), desc(eventBanners.createdAt));
    }
    async getActiveEventBanners() {
        return await db
            .select()
            .from(eventBanners)
            .where(eq(eventBanners.isActive, true))
            .orderBy(desc(eventBanners.priority), desc(eventBanners.createdAt));
    }
    async createEventBanner(bannerData) {
        const [banner] = await db
            .insert(eventBanners)
            .values(bannerData)
            .returning();
        return banner;
    }
    async updateEventBanner(id, updates) {
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
    async deleteEventBanner(id) {
        const result = await db
            .delete(eventBanners)
            .where(eq(eventBanners.id, id));
        return (result.rowCount ?? 0) > 0;
    }
}
export const storage = new DatabaseStorage();
//# sourceMappingURL=storage.js.map