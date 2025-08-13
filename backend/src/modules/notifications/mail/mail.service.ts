import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';
import * as handlebars from 'handlebars';
import * as fs from 'fs';
import * as path from 'path';

interface MailOptions {
  to: string;
  subject: string;
  template: string;
  context: Record<string, any>;
}

@Injectable()
export class MailService {
  private transporter: nodemailer.Transporter;
  private templatesDir: string;

  constructor(private configService: ConfigService) {
    // For development, we're using MailHog
    this.transporter = nodemailer.createTransport({
      host: configService.get('MAIL_HOST', 'mail-dev'),
      port: configService.get('MAIL_PORT', 1025),
      secure: false,
    });

    this.templatesDir = path.join(__dirname, 'templates');
  }

  async send(options: MailOptions): Promise<void> {
    try {
      const templatePath = path.join(this.templatesDir, `${options.template}.hbs`);
      
      // Check if template exists
      if (!fs.existsSync(templatePath)) {
        console.warn(`Email template not found: ${templatePath}`);
        return;
      }
      
      const templateSource = fs.readFileSync(templatePath, 'utf-8');
      const template = handlebars.compile(templateSource);
      const html = template(options.context);

      await this.transporter.sendMail({
        from: this.configService.get('MAIL_FROM', 'noreply@govconnect.com'),
        to: options.to,
        subject: options.subject,
        html,
      });
    } catch (error) {
      console.error('Failed to send email:', error);
    }
  }
}
