# Build stage
FROM node:20-alpine AS builder

# Install pnpm
RUN corepack enable && corepack prepare pnpm@10.23.0 --activate

WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source files
COPY . .

# Build the Sanity Studio
RUN pnpm build

# Production stage - serve static files
FROM node:20-alpine AS runner

RUN corepack enable && corepack prepare pnpm@10.23.0 --activate

WORKDIR /app

# Copy built files and package files
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./
COPY --from=builder /app/pnpm-lock.yaml ./

# Install only production dependencies
RUN pnpm install --frozen-lockfile --prod

# Cloud Run uses PORT environment variable
ENV PORT=8080
EXPOSE 8080

# Start Sanity Studio server
CMD ["pnpm", "start"]
