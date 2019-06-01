resource "aws_route" "private_default" {
  route_table_id         = local.core_route_table_ids[1]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.fortigate[1].id
}

resource "aws_eip" "fortigate" {
  vpc               = true
  network_interface = aws_network_interface.fortigate[0].id
}
