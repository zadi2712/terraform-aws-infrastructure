/**
 * Networking Layer - Outputs
 */

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = module.vpc.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = module.vpc.private_subnet_cidrs
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "List of NAT Gateway public IPs"
  value       = module.vpc.nat_gateway_public_ips
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.internet_gateway_id
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = module.vpc.availability_zones
}
