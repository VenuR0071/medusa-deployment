# Use the official Node.js 20 LTS image as the base
FROM node:22.17.0-alpine

# Set working directory inside the container
WORKDIR /app

# Copy package.json and yarn.lock
# Use --omit=dev during installation to prevent devDependencies from being installed
# but we need dev dependencies for the build step.
# So, we install all, then build, then prune.
# Copy package.json and yarn.lock
COPY medusa-backend/package.json ./
COPY medusa-backend/yarn.lock ./

# Install all dependencies (including devDependencies for build)
RUN yarn install --frozen-lockfile





# Copy the entire Medusa backend project
COPY medusa-backend/ .

# Add debug steps to see versions
RUN echo "--- Debugging Yarn dependency tree for Vite and Rollup and Zod ---"
RUN yarn why vite
RUN yarn why rollup
RUN yarn why zod # <--- ADD THIS NEW LINE
RUN echo "--- End Debugging ---"

# Build the Medusa project (transpile TypeScript to JavaScript)
RUN yarn build


# --- NEW ADDITIONS FOR ENTRYPOINT ---
#UN yarn run medusa build

# Remove devDependencies to keep image size small for production
RUN yarn install --frozen-lockfile --production=true

# --- TEMPORARY DEBUGGING STEPS: Add these lines ---
RUN echo "--- Inspecting /app/node_modules/@medusajs/admin/ directory ---"
RUN ls -la /app/node_modules/@medusajs/admin/ || echo "ERROR: @medusajs/admin directory not found or empty!"
RUN echo "--- Checking for specific files in @medusajs/admin ---"
RUN ls -la /app/node_modules/@medusajs/admin/index.js || echo "INFO: /app/node_modules/@medusajs/admin/index.js NOT FOUND"
RUN ls -la /app/node_modules/@medusajs/admin/dist/index.js || echo "INFO: /app/node_modules/@medusajs/admin/dist/index.js NOT FOUND"
RUN ls -la /app/node_modules/@medusajs/admin/main.js || echo "INFO: /app/node_modules/@medusajs/admin/main.js NOT FOUND"
RUN echo "--- Displaying content of @medusajs/admin/package.json ---"
RUN cat /app/node_modules/@medusajs/admin/package.json || echo "ERROR: Could not read @medusajs/admin/package.json!"
# --- END TEMPORARY DEBUGGING STEPS ---

# Copy the entrypoint script into the image
# Ensure entrypoint.sh is in the same directory as your Dockerfile (medusa-backend/)
COPY medusa-backend/entrypoint.sh /app/entrypoint.sh
# Make the entrypoint script executable
RUN chmod +x /app/entrypoint.sh

# Set this script as the ENTRYPOINT for the container
# This means /app/entrypoint.sh will be run first when the container starts.
ENTRYPOINT ["/app/entrypoint.sh"]

# --- END NEW ADDITIONS ---


# Expose the port Medusa runs on (default is 9000)
EXPOSE 9000

# Command to run the application
# Medusa's `start` script will typically run the compiled JS from `dist`
CMD ["yarn","start"]