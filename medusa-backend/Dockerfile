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

# Build the Medusa project (transpile TypeScript to JavaScript)
RUN yarn build

# Remove devDependencies to keep image size small for production
RUN yarn install --frozen-lockfile --production=true

# --- NEW ADDITIONS FOR ENTRYPOINT ---
RUN yarn run medusa build


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
CMD ["medusa","start"]