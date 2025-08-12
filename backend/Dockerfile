FROM node:20-alpine

# Install required tools
RUN apk add --no-cache wget postgresql-client redis

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies first (needed for build)
RUN npm ci && npm cache clean --force

# Copy source code
COPY . .

# Build application
RUN npm run build

# Remove dev dependencies after build
RUN npm prune --production

# Create uploads directory
RUN mkdir -p /app/uploads

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/health || exit 1

# Wait for services and start
CMD ["sh", "-c", "while ! pg_isready -h database -p 5432 -U postgres -q; do echo 'Waiting for database...'; sleep 2; done; while ! redis-cli -h redis -p 6379 ping > /dev/null 2>&1; do echo 'Waiting for Redis...'; sleep 2; done; echo 'Services ready!'; npm run start:prod"]