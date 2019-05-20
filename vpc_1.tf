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
  num_priv_subnets = 2
  priv_subnet_tags = [
    {
      Name = "Core-VPC-Private-Subnet-1"
    },
    {
      Name = "Core-VPC-Private-Subnet-2"
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

resource "aws_instance" "ec2_1a" {
  ami                         = data.aws_ami.amzn2_linux.id
  instance_type               = "t2.micro"
  key_name                    = "aws-dev-key"
  associate_public_ip_address = "true"
  subnet_id                   = element(module.vpc_1.public_subnets.*.id, 0)
  vpc_security_group_ids      = [element(aws_security_group.this.*.id, 0)]
  user_data                   = <<EOF
  #!/bin/bash -xe

  set -o xtrace
  sudo hostname ec2-1a-ssh-bastion
  sudo echo "ec2-1a-ssh-bastion" > /etc/hostname
EOF

}

resource "aws_instance" "ec2_1b" {
  ami = data.aws_ami.amzn2_linux.id
  instance_type = "t2.micro"
  key_name = "aws-dev-key"
  associate_public_ip_address = "false"
  subnet_id = element(module.vpc_1.private_subnets.*.id, 0)
  vpc_security_group_ids = [element(aws_security_group.this.*.id, 0)]

  user_data = <<EOF
  #!/bin/bash -xe

  set -o xtrace
  sudo hostname ec2-1b
  sudo echo "ec2-1b" > /etc/hostname
EOF

}

output "ec2_1a_public_ip" {
value = aws_instance.ec2_1a.public_ip
}

output "ec2_1a_private_ip" {
value = aws_instance.ec2_1a.private_ip
}

output "ec2_1b_private_ip" {
value = aws_instance.ec2_1b.private_ip
}