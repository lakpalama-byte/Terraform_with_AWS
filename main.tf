
 # initiate the provvider

# create the VPC
resource "aws_vpc" "production_vpc" {

    cidr_block= var.vpc_cidr
    tags= {
        Name="Production VPC"
    }
}


#Create the Internet Gateway

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.production_vpc.id
  
}

# creating an elastic ID to associate with NAT gateway

resource "aws_eip" "nat_eip" {

depends_on = [ aws_internet_gateway.igw ]   
} 

#create the NAT gateway

resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.public_subnet1.id
    tags= {

        Name="NAT Gateway"
    }
  
}


# create the public route tables

resource "aws_route_table" "public_rt" {

vpc_id=aws_vpc.production_vpc.id 
route {
    cidr_block = var.all_cidr
    gateway_id = aws_internet_gateway.igw.id

}  

tags = {
    Name="Public RT"
}
}


# create the private route table

resource "aws_route_table" "private_rt" {

vpc_id=aws_vpc.production_vpc.id 
route {
    cidr_block = var.all_cidr
    gateway_id = aws_nat_gateway.nat_gw.id

}  

tags = {
    Name="Private RT"
}
}



#Create the public subnet1
resource "aws_subnet" "public_subnet1" {
vpc_id=aws_vpc.production_vpc.id
cidr_block = var.public_subnet1_cidr
availability_zone = var.availability_zone
map_public_ip_on_launch = true
tags= {
    Name="Public Subnet 1"
}

}




#Create the public subnet2
resource "aws_subnet" "public_subnet2" {
vpc_id=aws_vpc.production_vpc.id
cidr_block = var.public_subnet2_cidr
availability_zone = "us-east-1b"
map_public_ip_on_launch = true 
tags= {
    Name="Public Subnet 2"
}

}

# create the private subnet

resource "aws_subnet" "private_subnet" {
vpc_id=aws_vpc.production_vpc.id
cidr_block = var.private_subnet_cidr
availability_zone = "us-east-1b"

tags= {
    Name="Private Subnet"
}

}


# route table association
# associate public RT with the public subnet1 
  resource "aws_route_table_association" "public_association1" {

    subnet_id =aws_subnet.public_subnet1.id
    route_table_id = aws_route_table.public_rt.id
    
  }


# route table associationte
# associate public RT with the public subnet2
  resource "aws_route_table_association" "public_association2" {

    subnet_id =aws_subnet.public_subnet2.id
    route_table_id = aws_route_table.public_rt.id
    
  }



# associate private  RT with the private subnet
  resource "aws_route_table_association" "private_association" {

    subnet_id =aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_rt.id
    
  }
