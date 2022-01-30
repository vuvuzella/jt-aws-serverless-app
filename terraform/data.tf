data "aws_vpc" "main_network" {
  id = "vpc-089db66b70fffa9df"
}

data "aws_subnet_ids" "main_subnets" {
  vpc_id = "vpc-089db66b70fffa9df" 
}
