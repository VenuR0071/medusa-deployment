import { loadEnv, defineConfig } from '@medusajs/framework/utils'

loadEnv(process.env.NODE_ENV || 'development', process.cwd())

module.exports = defineConfig({
  projectConfig: {
    databaseUrl: process.env.DATABASE_URL,
    http: {
      storeCors: process.env.STORE_CORS!,
      adminCors: process.env.ADMIN_CORS!,
      authCors: process.env.AUTH_CORS!,
      jwtSecret: process.env.JWT_SECRET || "supersecret",
      cookieSecret: process.env.COOKIE_SECRET || "supersecret",
    }
  },
  modules: {
    file: {
      resolve: "@medusajs/file", // The core file module
      options: {
        providers: [ // Configure providers for the file module
          {
            resolve: "@medusajs/file-s3", // The S3 provider for the file module
            id: "s3-provider", // A unique ID for this provider
            options: {
              bucket: process.env.S3_BUCKET,
              region: process.env.S3_REGION,
              // The S3_URL is automatically constructed by the provider based on bucket and region
              // You generally don't need access_key_id/secret_access_key if using IAM roles on ECS
              access_key_id: process.env.AWS_ACCESS_KEY_ID,
              secret_access_key: process.env.AWS_SECRET_ACCESS_KEY,
              cache_control: "max-age=31536000",
            },
          },
        ],
      },
    },
  }
})
