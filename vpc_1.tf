provider "aws" {
}

### VPC
module "vpc_1" {
  source = "../modules/aws/vpc"

  # source = "git::ssh://git@github.com/IPyandy/terraform-aws-modules.git//vpc?ref=terraform-0.12"

  ### VPC
  create_vpc = true

  azs = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
  ]

  cidr_block                      = "10.244.0.0/16"
  instance_tenancy                = "default"
  enable_dns_hostnames            = true
  enable_dns_support              = true
  enable_classic_link             = false
  enable_classic_link_dns_support = false

  ### DHCP OPTIONS
  create_dhcp_options      = true
  dhcp_domain_name         = var.domain_name
  dhcp_domain_name_servers = ["AmazonProvidedDNS"]

  dhcp_ntp_servers = [
    "69.195.159.158",
    "173.255.206.153",
  ]

  dhcp_netbios_name_servers = []
  dhcp_netbios_node_type    = 2

  #############################################################################
  ### IPv4 SUBNETS
  #############################################################################

  map_public      = true
  num_pub_subnets = 1
  pub_subnet_tags = [
    {
      Name = "Core-VPC-Public-Subnet"
    },
  ]
  num_priv_subnets = 1
  priv_subnet_tags = [
    {
      Name = "Core-VPC-Private-Subnet-1"
    },
  ]
  ipv4_priv_newbits = 8
  ipv4_priv_netnum  = 128

  ### ROUTING AND INTERNET
  #############################################################################

  create_inet_gw = true
  num_nat_gws    = 1

  #############################################################################
  ### FLOWLOGS
  #############################################################################

  create_flow_log     = true
  flow_log_group_name = "Core-VPC-flowlog"

  #############################################################################
  ### ALL TAGS
  #############################################################################

  vpc_tags = {
    Name = "Core-VPC"
  }
}
