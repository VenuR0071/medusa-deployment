# --- Stage 1: Builder ---
# Uses Node.js 22 LTS Alpine for a smaller base image for building
FROM node:22.17.0-alpine AS builder

# Set working directory inside the container for the build process
WORKDIR /app

# Copy package.json and yarn.lock first to leverage Docker layer caching.
# If these files don't change, this layer and subsequent yarn install can be cached.
# Assuming your Dockerfile is in `medusa-deployment/` and your backend is in `medusa-backend/`
COPY medusa-backend/package.json ./
COPY medusa-backend/yarn.lock ./

# Install all dependencies (including devDependencies needed for the build step).
# Using --frozen-lockfile ensures reproducible builds.
RUN yarn install --frozen-lockfile

# Copy the entire Medusa backend project source code into the builder stage.
# This includes src/, medusa-config.js, .env (if you want to build with it), etc.
COPY medusa-backend/ .

# Build the Medusa project.
# This command will:
# 1. Transpile your TypeScript backend code into JavaScript (into .medusa/server).
# 2. Build the Admin UI frontend assets (into .medusa/server/public/admin/ by default).
RUN yarn build

# --- Stage 2: Production Runtime ---
# Use a fresh, minimal Node.js 22 LTS Alpine image for the final production container.
FROM node:22.17.0-alpine AS production

# Set working directory for the runtime application
WORKDIR /app

# Copy only the production node_modules from the builder stage.
# This significantly reduces the final image size by excluding devDependencies.
COPY --from=builder /app/node_modules ./node_modules

# Copy the built backend server and its integrated Admin UI assets.
# Your local check confirmed .medusa/server contains everything needed for the backend.
# Copying /app/.medusa/server/ to /app/ means:
# - Transpiled backend code will be in /app/dist (if default output is dist) or directly under /app/
#   depending on how Medusa builds into .medusa/server.
# - The Admin UI (index.html, etc.) will be at /app/public/admin/index.html in the final image.
#   This is the standard path Medusa uses when serving the integrated admin.
COPY --from=builder /app/.medusa/server/ ./

# Copy other essential runtime files that are not part of .medusa/server.
# This typically includes:
# - medusa-config.js (or .ts if transpiled separately)
# - Any custom plugins, services, subscribers, etc. if they are not already in .medusa/server.
# Since `medusa build` handles transpilation, ensure you copy the *compiled* versions or just
# the necessary config files. For simplicity, if your medusa-config.js is at the root
# of your backend, copy it.
COPY medusa-backend/medusa-config.js ./
# If you have an .env file or specific custom files needed at runtime (not built)
# COPY medusa-backend/.env ./.env
# COPY medusa-backend/src/some-custom-file.js ./src/some-custom-file.js

# Copy the entrypoint script into the image.
# Ensure entrypoint.sh is in the same directory as your Dockerfile (medusa-deployment/)
COPY medusa-backend/entrypoint.sh /app/entrypoint.sh
# Make the entrypoint script executable
RUN chmod +x /app/entrypoint.sh

# Set environment variables for production.
# This ensures Medusa runs in production mode.
ENV NODE_ENV=production

# Expose the port Medusa runs on (default is 9000)
EXPOSE 9000

# Set this script as the ENTRYPOINT for the container.
# This means /app/entrypoint.sh will be run first when the container starts.
ENTRYPOINT ["/app/entrypoint.sh"]

# Command to run the application.
# Medusa's `start` script will typically run the compiled JS.
CMD ["yarn", "start"]