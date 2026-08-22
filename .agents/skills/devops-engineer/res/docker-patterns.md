# Docker Patterns

This file contains concrete examples of multi-stage `Dockerfile` templates with non-root users. Apply these patterns when writing or modifying Dockerfiles for the Dungeoneer backend.

## Spring Boot Multi-Stage Dockerfile Pattern

```dockerfile
# Stage 1: Build dependencies and compile
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /app
# Explict layer caching for dependencies
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN ./mvnw dependency:go-offline

# Copy source and build
COPY src src
RUN ./mvnw clean package -DskipTests

# Stage 2: Minimal runtime image
FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app

# Create a non-root user and group
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy the built jar from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose standard port
EXPOSE 8080

# Execute
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## Node.js (Next.js) Multi-Stage Pattern

```dockerfile
# Stage 1: Install dependencies
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# Stage 2: Build application
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# Stage 3: Production environment
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy required files for Next.js standalone output
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000
ENV PORT 3000

CMD ["node", "server.js"]
```
