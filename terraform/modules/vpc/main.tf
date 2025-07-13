
    resource "aws_vpc" "main" {
      cidr_block = var.vpc_cidr_block
      enable_dns_support = true
      enable_dns_hostnames = true

      tags = {
        Name = "${var.project_name}-vpc"
      }
    }

    resource "aws_internet_gateway" "main" {
      vpc_id = aws_vpc.main.id

      tags = {
        Name = "${var.project_name}-igw"
      }
    }

    resource "aws_subnet" "public" {
      count = length(var.public_subnet_cidr_blocks)
      vpc_id = aws_vpc.main.id
      cidr_block = var.public_subnet_cidr_blocks[count.index]
      availability_zone = "${var.aws_region}${element(["a", "b", "c"], count.index)}"
      map_public_ip_on_launch = true

      tags = {
        Name = "${var.project_name}-public-subnet-${count.index + 1}"
      }
    }

    resource "aws_subnet" "private" {
      count = length(var.private_subnet_cidr_blocks)
      vpc_id = aws_vpc.main.id
      cidr_block = var.private_subnet_cidr_blocks[count.index]
      availability_zone = "${var.aws_region}${element(["a", "b", "c"], count.index)}"

      tags = {
        Name = "${var.project_name}-private-subnet-${count.index + 1}"
      }
    }

    resource "aws_subnet" "database" {
      count = length(var.database_subnet_cidr_blocks)
      vpc_id = aws_vpc.main.id
      cidr_block = var.database_subnet_cidr_blocks[count.index]
      availability_zone = "${var.aws_region}${element(["a", "b", "c"], count.index)}"

      tags = {
        Name = "${var.project_name}-database-subnet-${count.index + 1}"
      }
    }

    resource "aws_route_table" "public" {
      vpc_id = aws_vpc.main.id

      route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
      }

      tags = {
        Name = "${var.project_name}-public-rt"
      }
    }

    resource "aws_route_table_association" "public" {
      count = length(aws_subnet.public)
      subnet_id = aws_subnet.public[count.index].id
      route_table_id = aws_route_table.public.id
    }

    resource "aws_eip" "nat_gateway" {
      count = length(var.public_subnet_cidr_blocks) # One NAT Gateway per public subnet (for redundancy)
      domain = "vpc"
      depends_on = [aws_internet_gateway.main]

      tags = {
        Name = "${var.project_name}-nat-eip-${count.index + 1}"
      }
    }

    resource "aws_nat_gateway" "main" {
      count = length(var.public_subnet_cidr_blocks) # One NAT Gateway per public subnet (for redundancy)
      allocation_id = aws_eip.nat_gateway[count.index].id
      subnet_id = aws_subnet.public[count.index].id
      depends_on = [aws_internet_gateway.main]

      tags = {
        Name = "${var.project_name}-nat-gateway-${count.index + 1}"
      }
    }

    resource "aws_route_table" "private" {
      count = length(var.private_subnet_cidr_blocks)
      vpc_id = aws_vpc.main.id

      route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main[count.index].id # Route traffic to respective NAT Gateway
      }

      tags = {
        Name = "${var.project_name}-private-rt-${count.index + 1}"
      }
    }

    resource "aws_route_table_association" "private" {
      count = length(aws_subnet.private)
      subnet_id = aws_subnet.private[count.index].id
      route_table_id = aws_route_table.private[count.index].id
    }

    # Database Subnets do NOT need NAT Gateway, as they should be fully private
    resource "aws_route_table" "database" {
      count = length(var.database_subnet_cidr_blocks)
      vpc_id = aws_vpc.main.id
      # No default route to IGW or NAT Gateway, keeping them isolated.

      tags = {
        Name = "${var.project_name}-database-rt-${count.index + 1}"
      }
    }

    resource "aws_route_table_association" "database" {
      count = length(aws_subnet.database)
      subnet_id = aws_subnet.database[count.index].id
      route_table_id = aws_route_table.database[count.index].id
    }


    # --- Security Groups ---
    resource "aws_security_group" "alb" {
      vpc_id      = aws_vpc.main.id
      name        = "${var.project_name}-alb-sg"
      description = "Security group for ALB, allowing HTTP/HTTPS from anywhere"

      ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }

      tags = {
        Name = "${var.project_name}-alb-sg"
      }
    }

    resource "aws_security_group" "app" {
      vpc_id      = aws_vpc.main.id
      name        = "${var.project_name}-app-sg"
      description = "Security group for Medusa backend containers, allowing inbound from ALB"

      ingress {
        from_port   = 9000 # Medusa's default port
        to_port     = 9000
        protocol    = "tcp"
        security_groups = [aws_security_group.alb.id] # Allow traffic only from ALB
      }
      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"] # Allow all outbound for now (restrict later if needed)
      }

      tags = {
        Name = "${var.project_name}-app-sg"
      }
    }

    resource "aws_security_group" "db" {
      vpc_id      = aws_vpc.main.id
      name        = "${var.project_name}-db-sg"
      description = "Security group for RDS PostgreSQL, allowing inbound from app containers"

      ingress {
        from_port   = 5432 # PostgreSQL default port
        to_port     = 5432
        protocol    = "tcp"
        security_groups = [aws_security_group.app.id] # Allow traffic only from App SG
      }
      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }

      tags = {
        Name = "${var.project_name}-db-sg"
      }
    }

    resource "aws_security_group" "redis" {
      vpc_id      = aws_vpc.main.id
      name        = "${var.project_name}-redis-sg"
      description = "Security group for ElastiCache Redis, allowing inbound from app containers"

      ingress {
        from_port   = 6379 # Redis default port
        to_port     = 6379
        protocol    = "tcp"
        security_groups = [aws_security_group.app.id] # Allow traffic only from App SG
      }
      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }

      tags = {
        Name = "${var.project_name}-redis-sg"
      }
    }

