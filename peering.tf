resource "aws_vpc_peering_connection" "default" {
  count       = var.isPeeringRequired ? 1 : 0
  vpc_id      = aws_vpc.roboshop.id     #Requestor
  peer_vpc_id = data.aws_vpc.default.id 
  #Acceptor
  auto_accept =  true 

   tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-default"
        }
    )
}

resource "aws_route" "public_peering" {
  count = var.isPeeringRequired ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id  = aws_vpc_peering_connection.default[count.index].id
}


resource "aws_route" "private_peering" {
  count = var.isPeeringRequired ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id  = aws_vpc_peering_connection.default[count.index].id
}

resource "aws_route" "database_peering" {
  count = var.isPeeringRequired ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id  = aws_vpc_peering_connection.default[count.index].id
}


resource "aws_route" "default_peering" {
  count = var.isPeeringRequired ? 1 : 0
  route_table_id            = data.aws_route_table.default.id
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id  = aws_vpc_peering_connection.default[count.index].id
}

