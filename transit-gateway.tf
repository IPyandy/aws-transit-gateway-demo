module "transit_gateway" {
  ## Transit Gateway
  source = "git::ssh://git@github.com/IPyandy/terraform-aws-modules.git//transit-gateway?ref=terraform-0.12"

  create_transit_gateway          = true
  transit_gateway_description     = "Transit Gateway Demo"
  amazon_side_asn                 = 65100
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  transit_gateway_tags = {
    Name = "Transit-Gateway-01"
  }

  ## VPC Attachments
  vpc_ids      = concat(local.core_vpc_ids, local.spoke_vpc_ids)
  subnet_ids   = [local.core_private_subnet_ids, local.spoke_1_subnet_ids, local.spoke_2_subnet_ids]
  ipv6_support = "disable"

  ### Because default route table association and propagation are set a the
  ### transit gateway level, these two settings are redundant, but its nice
  ### to be verbose sometimes to declare intent.
  associate_default_route_table       = true
  vpc_default_route_table_propagation = true
  vpc_attachment_tags = [
    {
      Name = "Core VPC Attachment"
    },
    {
      Name = "Spoke-1 VPC Attachment"
    },
    {
      Name = "Spoke-2 VPC Attachment"
    }
  ]
}

resource "aws_ec2_transit_gateway_route" "default_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.transit_gateway.vpc_attachment_ids[0]
  transit_gateway_route_table_id = module.transit_gateway.default_route_table_id
}

resource "aws_route" "core_routes" {
  count                  = length(local.core_route_table_ids)
  route_table_id         = local.core_route_table_ids[count.index]
  destination_cidr_block = "10.244.0.0/14"
  transit_gateway_id     = module.transit_gateway.transit_gateway_id
}

resource "aws_route" "spoke_default_routes" {
  count                  = length(local.spoke_priv_route_table_ids)
  route_table_id         = local.spoke_priv_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.transit_gateway.transit_gateway_id
}
