module "vpc_2" {
  source = "../modules/aws/vpc"

  # source = "git::ssh://git@github.com/IPyandy/terraform-aws-modules.git//vpc?ref=terraform-0.12"

  ### VPC
  create_vpc = true

  azs = [
    "us-east-1d",
    "us-east-1e",
    "us-east-1f",
  ]

  cidr_block                      = "10.245.0.0/16"
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

  num_pub_subnets  = 0
  num_priv_subnets = 1
  priv_subnet_tags = [
    {
      Name = "Stub-1-VPC-Private-Subnet-1"
    },
  ]
  ipv4_priv_newbits = 8
  ipv4_priv_netnum  = 128

  ### ROUTING AND INTERNET
  #############################################################################

  create_inet_gw = false
  num_nat_gws    = 0

  #############################################################################
  ### FLOWLOGS
  #############################################################################

  create_flow_log     = true
  flow_log_group_name = "Stub-1-VPC-flowlog"

  #############################################################################
  ### ALL TAGS
  #############################################################################

  vpc_tags = {
    Name = "Stub-1-VPC"
  }
}

resource "aws_instance" "ec2_2" {
  ami                         = data.aws_ami.latest-ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = "aws-dev-key"
  associate_public_ip_address = "false"
  subnet_id                   = element(module.vpc_2.private_subnets.*.id, 0)
  vpc_security_group_ids      = [element(aws_security_group.this.*.id, 1)]
  user_data                   = <<EOF
  #!/usr/bin/bash -xe

  set -o xtrace
  sudo hostname ec2-2

EOF

}

output "ec2_2_private_ip" {
  value = aws_instance.ec2_2.private_ip
}
