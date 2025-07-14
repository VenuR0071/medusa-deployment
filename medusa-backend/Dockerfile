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


# --- TEMPORARY DEBUGGING STEPS: Add these lines ---
RUN echo "--- Verifying existence and content of @types/bonjour ---"
RUN ls -la /app/node_modules/@types/bonjour || echo "ERROR: @types/bonjour directory not found!"
RUN ls -la /app/node_modules/@types/bonjour/index.d.ts || echo "ERROR: @types/bonjour/index.d.ts not found!"

RUN echo "--- Verifying existence and content of @types/json-schema ---"
RUN ls -la /app/node_modules/@types/json-schema || echo "ERROR: @types/json-schema directory not found!"
RUN ls -la /app/node_modules/@types/json-schema/index.d.ts || echo "ERROR: @types/json-schema/index.d.ts not found!"

RUN echo "--- Verifying existence and content of @types/parse-json ---"
RUN ls -la /app/node_modules/@types/parse-json || echo "ERROR: @types/parse-json directory not found!"
RUN ls -la /app/node_modules/@types/parse-json/index.d.ts || echo "ERROR: @types/parse-json/index.d.ts not found!"

RUN echo "--- Verifying existence and content of @types/resolve ---"
RUN ls -la /app/node_modules/@types/resolve || echo "ERROR: @types/resolve directory not found!"
RUN ls -la /app/node_modules/@types/resolve/index.d.ts || echo "ERROR: @types/resolve/index.d.ts not found!"

RUN echo "--- Showing first 30 entries in /app/node_modules/@types/ (partial list) ---"
RUN ls -la /app/node_modules/@types/ | head -n 30
# --- END TEMPORARY DEBUGGING STEPS ---


# Copy the entire Medusa backend project
COPY medusa-backend/ .

# Build the Medusa project (transpile TypeScript to JavaScript)
RUN yarn build


# --- NEW ADDITIONS FOR ENTRYPOINT ---
#UN yarn run medusa build

# Remove devDependencies to keep image size small for production
RUN yarn install --frozen-lockfile --production=true




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