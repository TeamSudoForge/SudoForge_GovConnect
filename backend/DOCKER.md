# Docker Services Configuration

Essential services for the NestJS authentication backend:

- Backend: NestJS API server with authentication
- Database: PostgreSQL with auto-initialization  
- File Storage: MinIO S3-compatible storage
- Mail Dev: MailHog for email testing
- Redis: Session management and caching
- pgAdmin: Database administration (production only)

## Quick Start

### Start Development Environment
```bash
npm run docker:dev
```

### Stop Services
```bash
npm run docker:dev:stop
```

## Service URLs & Ports

### Development Services
- **Backend API**: http://localhost:3000
- **Health Check**: http://localhost:3000/health
- **Database**: localhost:5432 (postgres/password)
- **File Storage**: http://localhost:9001 (minioadmin/minioadmin123)
- **Mail Dev**: http://localhost:8025  
- **Redis**: localhost:6379

### Production (adds pgAdmin)
- **Database Admin**: http://localhost:5050 (admin@govconnect.com/admin123)

## Container Details

| Service | Image | Port | Purpose |
|---------|--------|------|---------|
| backend | node:18-alpine | 3000 | NestJS API server |
| database | postgres:15-alpine | 5432 | PostgreSQL database |
| file-storage | minio/minio | 9000/9001 | S3-compatible storage |
| mail-dev | mailhog/mailhog | 1025/8025 | Email testing |
| redis | redis:7-alpine | 6379 | Session/cache store |
| pgadmin | dpage/pgadmin4 | 5050 | DB admin (prod only) |

## Security Features

- **Network isolation**: All services in private Docker network
- **Health checks**: Automated monitoring for all services  
- **Data persistence**: Named volumes for critical data
- **Environment separation**: Different configs for dev/prod
- **Restart policies**: Automatic recovery from failures

This simplified setup gives you a **stable, minimal environment** perfect for developing and testing your authentication system!
   curl -X POST http://localhost:3000/auth/register \
     -H "Content-Type: application/json" \
     -d '{
       "email": "test@example.com",
       "password": "password123",
       "firstName": "John",
       "lastName": "Doe", 
       "username": "johndoe"
     }'
   ```

4. **Open test frontend**:
   Open `test-frontend.html` in your browser

## Available Commands

### Development
```bash
npm run docker:dev          # Start development environment
npm run docker:dev:stop     # Stop development environment  
npm run docker:dev:logs     # View backend logs
npm run docker:status       # Check container status
```

### Production
```bash
npm run docker:prod         # Start production environment
npm run docker:prod:stop    # Stop production environment
```

### Database Operations
For database operations, use Docker Compose directly:
```bash
# Create backup
docker-compose exec -T database pg_dump -U postgres govconnect > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore backup
docker-compose exec -T database psql -U postgres govconnect < backup_file.sql

# Reset database (destroys all data)
docker-compose down -v && docker-compose up -d database
```

### Cleanup
```bash
npm run docker:cleanup      # Clean up Docker resources
```

## What's Different (No Nginx)

### Before (with Nginx):
- Frontend served on port 80
- API proxied through /api/ path
- More complex routing

### Now (simplified):
- **Direct backend access** on port 3000
- **No proxy layer** to debug
- **Faster startup** time
- **Simpler architecture** for development

## When to Add Nginx Back

You'll want to add Nginx when you:
- Build a frontend application (React/Next.js)
- Need load balancing for multiple backend instances
- Deploy to production with custom domain
- Want advanced caching and compression

## Container Details

| Service | Image | Port | Purpose |
|---------|--------|------|---------|
| backend | node:18-alpine | 3000 | NestJS API server |
| database | postgres:15-alpine | 5432 | PostgreSQL database |
| file-storage | minio/minio | 9000/9001 | S3-compatible storage |
| mail-dev | mailhog/mailhog | 1025/8025 | Email testing |
| redis | redis:7-alpine | 6379 | Session/cache store |
| pgadmin | dpage/pgadmin4 | 5050 | DB admin (prod only) |

## Security Features

- **Network isolation**: All services in private Docker network
- **Health checks**: Automated monitoring for all services  
- **Data persistence**: Named volumes for critical data
- **Environment separation**: Different configs for dev/prod
- **Restart policies**: Automatic recovery from failures

This simplified setup gives you a **stable, minimal environment** perfect for developing and testing your authentication system!
