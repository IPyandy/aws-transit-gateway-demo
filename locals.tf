locals {
  vpc_ids = [
    module.core_vpc.vpc_id,
    module.spoke_1_vpc.vpc_id,
    module.spoke_2_vpc.vpc_id,
  ]
  core_vpc_ids = [module.core_vpc.vpc_id]
  stub_vpc_ids = [module.spoke_1_vpc.vpc_id, module.spoke_2_vpc.vpc_id]
  cidr_blocks = [
    module.core_vpc.cidr_block,
    module.spoke_1_vpc.cidr_block,
    module.spoke_2_vpc.cidr_block,
  ]
  stub_subnet_ids = concat(
    module.spoke_1_vpc.private_subnets.*.id,
    module.spoke_2_vpc.private_subnets.*.id,
  )
  stub1_subnet_ids = module.spoke_1_vpc.private_subnets.*.id
  stub2_subnet_ids = module.spoke_2_vpc.private_subnets.*.id
  core_subnet_ids = concat(
    module.core_vpc.private_subnets.*.id,
    module.core_vpc.public_subnets.*.id,
  )
  subnet_ids = concat(
    module.core_vpc.private_subnets.*.id,
    module.core_vpc.public_subnets.*.id,
    module.spoke_1_vpc.private_subnets.*.id,
    module.spoke_2_vpc.private_subnets.*.id,
  )
  core_public_subnet_ids    = module.core_vpc.public_subnets.*.id
  core_private_subnet_ids   = module.core_vpc.private_subnets.*.id
  core_pub_route_table_ids  = module.core_vpc.public_route_tables.*.id
  core_priv_route_table_ids = module.core_vpc.private_route_tables.*.id
  core_route_table_ids = concat(
    module.core_vpc.public_route_tables.*.id,
    module.core_vpc.private_route_tables.*.id,
  )
  stub_priv_route_table_ids = concat(
    module.spoke_1_vpc.private_route_tables.*.id,
    module.spoke_2_vpc.private_route_tables.*.id,
  )
  stub_route_table_ids = concat(
    module.spoke_1_vpc.private_route_tables.*.id,
    module.spoke_2_vpc.private_route_tables.*.id,
  )
}
