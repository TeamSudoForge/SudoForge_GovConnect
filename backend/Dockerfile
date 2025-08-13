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

# Create entrypoint script to run migrations before starting the app
RUN echo '#!/bin/sh\n\
echo "Running migrations..."\n\
npm run migration:run\n\
echo "Starting application..."\n\
exec npm run start:prod\n' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

# Wait for services and start
CMD ["/app/entrypoint.sh"]