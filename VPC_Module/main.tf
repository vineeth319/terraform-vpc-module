resource "aws_vpc" "roboshop" {
  cidr_block         = var.cidr_block
  enable_dns_support = true

  tags = merge(
    local.common_tags,
    var.vpc_tags,
    {
      Name = local.name
    }
  )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.roboshop.id
  tags = merge(
    local.common_tags,
    var.igw_tags,
    {
      Name = local.name
    }
  )
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.roboshop.id
  count                   = length(var.public_subnet_cidrs)
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, var.public_subnet_tags, {
    Name = "${local.name}-public-${local.az_names[count.index]}"
    }
  )
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.roboshop.id
  count      = length(var.private_subnet_cidrs)
  cidr_block = var.private_subnet_cidrs[count.index]
  tags = merge(local.common_tags, var.private_subnet_tags, {
    Name = "${local.name}-private-${local.az_names[count.index]}"
    }
  )
}

resource "aws_subnet" "database" {
  vpc_id     = aws_vpc.roboshop.id
  count      = length(var.database_subnet_cidrs)
  cidr_block = var.database_subnet_cidrs[count.index]
  tags = merge(
    local.common_tags, 
    var.database_subnet_tags,
    {
      Name = "${local.name}-database-${local.az_names[count.index]}"
    }
  )
}

resource "aws_eip" "eip" {
  domain = "vpc"
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-nat"
    },
    var.eip_tags
  )
}

resource "aws_nat_gateway" "roboshop_nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    local.common_tags,
    var.nat_gateway_tags,
    {
      Name = "${local.name}-NAT"
    }
  )
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.roboshop.id
  tags = merge(
    local.common_tags,
    var.public_route_table_tags,
    {
      Name = "${local.name}-public"
    }
  )

}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.roboshop.id
  tags = merge(
    local.common_tags,
    var.private_route_table_tags,
    {
      Name = "${local.name}-private"
    }
  )

}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.roboshop.id
  tags = merge(
    local.common_tags,
    var.database_route_table_tags,
    {
      Name = "${local.name}-database"
    }
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}


resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.roboshop_nat.id
}

resource "aws_route" "database" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.roboshop_nat.id
}


resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count          = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

resource "aws_db_subnet_group" "roboshop" {
  name       = "${var.project}-${var.environment}"
  subnet_ids = [aws_subnet.database[0].id,aws_subnet.database[1].id]

  tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        }
  )
}