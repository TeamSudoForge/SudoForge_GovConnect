import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as path from 'path';
import * as fs from 'fs';
import { Express } from 'express';
import { Client as MinioClient } from 'minio';

export interface UploadOptions {
  folder?: string;
  contentType?: string;
  filename?: string; // override original filename
}

export interface UploadResult {
  key: string;
  url: string;
}

@Injectable()
export class StorageService {
  private driver: 'local' | 'minio';
  private minio?: MinioClient;
  private minioBucket?: string;
  private minioPublicUrl?: string | undefined;

  constructor(private readonly config: ConfigService) {
    this.driver = (this.config.get<string>('STORAGE_DRIVER') || 'minio') as 'local' | 'minio';

    if (this.driver === 'minio') {
      const endPoint = this.config.get<string>('MINIO_ENDPOINT', 'file-storage');
      const port = Number(this.config.get<string>('MINIO_PORT', '9000'));
      const useSSL = (this.config.get<string>('MINIO_USE_SSL', 'false') || 'false') === 'true';
      const accessKey = this.config.get<string>('MINIO_ACCESS_KEY', 'minioadmin');
      const secretKey = this.config.get<string>('MINIO_SECRET_KEY', 'minioadmin123');
      this.minioBucket = this.config.get<string>('MINIO_BUCKET', 'uploads');
      this.minioPublicUrl = this.config.get<string>('MINIO_PUBLIC_URL');

      this.minio = new MinioClient({ endPoint, port, useSSL, accessKey, secretKey });
    }
  }

  async ensureBucket(): Promise<void> {
    if (this.driver !== 'minio' || !this.minio || !this.minioBucket) return;
    const exists = await this.minio.bucketExists(this.minioBucket).catch(() => false);
    if (!exists) {
      await this.minio.makeBucket(this.minioBucket, 'us-east-1');
      // Make bucket public by default (optional). Comment out if not desired.
      try {
        const policy = {
          Version: '2012-10-17',
          Statement: [
            {
              Effect: 'Allow',
              Principal: { AWS: ['*'] },
              Action: ['s3:GetObject'],
              Resource: [`arn:aws:s3:::${this.minioBucket}/*`],
            },
          ],
        };
        await this.minio.setBucketPolicy(this.minioBucket, JSON.stringify(policy));
      } catch {
        // ignore policy errors in dev
      }
    }
  }

  async upload(file: Express.Multer.File | Buffer, options: UploadOptions = {}): Promise<UploadResult> {
    const folder = (options.folder || '').replace(/^\/+|\/+$/g, '');
    const originalName = typeof file === 'object' && 'originalname' in file ? file.originalname : options.filename || `upload_${Date.now()}`;
    const filename = options.filename || originalName;
    const key = folder ? `${folder}/${filename}` : filename;

    if (this.driver === 'minio' && this.minio && this.minioBucket) {
      await this.ensureBucket();
      const contentType = (typeof file === 'object' && 'mimetype' in file && file.mimetype) || options.contentType || 'application/octet-stream';
      const buffer: Buffer = Buffer.isBuffer(file) ? file : file.buffer;
      await this.minio.putObject(this.minioBucket, key, buffer, { 'Content-Type': contentType });

      let url: string;
      if (this.minioPublicUrl) {
        const base = this.minioPublicUrl.replace(/\/$/, '');
        url = `${base}/${this.minioBucket}/${encodeURI(key)}`;
      } else {
        const endPoint = this.config.get<string>('MINIO_ENDPOINT', 'localhost');
        const port = this.config.get<string>('MINIO_PORT', '9000');
        const useSSL = (this.config.get<string>('MINIO_USE_SSL', 'false') || 'false') === 'true';
        const scheme = useSSL ? 'https' : 'http';
        url = `${scheme}://${endPoint}:${port}/${this.minioBucket}/${encodeURI(key)}`;
      }
      return { key, url };
    }

    // local fallback
    const uploadsDir = path.join(process.cwd(), 'uploads');
    const targetDir = folder ? path.join(uploadsDir, folder) : uploadsDir;
    await fs.promises.mkdir(targetDir, { recursive: true }).catch(() => undefined);
    const targetPath = path.join(targetDir, filename);
    const buffer: Buffer = Buffer.isBuffer(file) ? file : file.buffer;
    await fs.promises.writeFile(targetPath, buffer).catch((e) => {
      throw new InternalServerErrorException(e.message);
    });
    const url = `/uploads/${encodeURI(folder ? `${folder}/` : '')}${encodeURI(filename)}`;
    return { key, url };
  }

  async remove(key: string): Promise<void> {
    if (this.driver === 'minio' && this.minio && this.minioBucket) {
      await this.minio.removeObject(this.minioBucket, key);
      return;
    }
    const uploadsDir = path.join(process.cwd(), 'uploads');
    const targetPath = path.join(uploadsDir, key);
    await fs.promises.unlink(targetPath).catch(() => undefined);
  }
}


