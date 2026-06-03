resource "aws_vpc_peering_connection" "default" {
  count =  var.is_peering_required ? 1 : 0 
 
  peer_vpc_id   = data.aws_vpc.default.id   # Acceptor VPC which is default here
  vpc_id        = aws_vpc.main.id           # Requestor VPC 

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  auto_accept = true

  tags = merge(
    var.vpc_peering_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-default"
    }
  )

}

#Route -- Public 
resource "aws_route" "public_peering" {
  count =  var.is_peering_required ? 1 : 0

  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

#Route -- Private 
resource "aws_route" "private_peering" {
  count =  var.is_peering_required ? 1 : 0

  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

#Route -- Public 
resource "aws_route" "database_peering" {
  count =  var.is_peering_required ? 1 : 0

  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

## We should add peering connection in default VPC main route table too.
resource "aws_route" "default_peering" {
  count =  var.is_peering_required ? 1 : 0

  route_table_id            = data.aws_route_table.main.id
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}
