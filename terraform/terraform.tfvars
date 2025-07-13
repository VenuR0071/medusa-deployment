# terraform/terraform.tfvars
db_username = "postgres"
db_password = "12345678" # Replace with a strong password
store_cors  = "http://localhost:8000,https://your-storefront-domain.com" # Example: adjust for your storefront
admin_cors  = "http://localhost:7000,https://your-admin-domain.com" # Example: adjust for your admin dashboard
auth_cors   = "http://localhost:7000,http://localhost:8000,https://your-admin-domain.com,https://your-storefront-domain.com" # Example: for Medusa v2 authentication