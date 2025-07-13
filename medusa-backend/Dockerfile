# Use the official Node.js 20 LTS image as the base
FROM node:20.11.0-alpine

# Set working directory inside the container
WORKDIR /app

# Copy package.json and yarn.lock
# Use --omit=dev during installation to prevent devDependencies from being installed
# but we need dev dependencies for the build step.
# So, we install all, then build, then prune.
COPY medusa-backend/package*.json ./

# Install all dependencies (including devDependencies for build)
RUN yarn install --frozen-lockfile

# Copy the entire Medusa backend project
COPY medusa-backend/ .

# Build the Medusa project (transpile TypeScript to JavaScript)
RUN yarn build

# Remove devDependencies to keep image size small for production
RUN yarn install --frozen-lockfile --production=true

# Expose the port Medusa runs on (default is 9000)
EXPOSE 9000

# Command to run the application
# Medusa's `start` script will typically run the compiled JS from `dist`
CMD ["yarn", "start"]