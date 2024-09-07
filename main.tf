
 # initiate the provvider]



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



#Security group

#Create jenkins security groups

resource "aws_security_group" "jenkins_sg" {
  name        = "Jenkins SG"
  description = "allow ports 8080 and 22"
  vpc_id      = aws_vpc.production_vpc.id

  ingress = [
    {
      description      = "jenkins"
      from_port        = var.jenkins_port
      to_port          = var.jenkins_port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []  # Optional: Add if you need to allow IPv6 addresses
      prefix_list_ids  = []  # Optional: Add if you need to use AWS prefix lists
      security_groups  = []  # Optional: Add if you need to allow other security groups
      self             = false  # Optional: Set to true if you need to allow traffic from itself
    },
    {
      description      = "SSH"
      from_port        = var.SSH_port
      to_port          = var.SSH_port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []  # Optional
      prefix_list_ids  = []  # Optional
      security_groups  = []  # Optional
      self             = false  # Optional
    }
  ]

  egress = [
    {  description = "allow all outbound traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []  # Optional
      prefix_list_ids  = []  # Optional
      security_groups  = []  # Optional
      self             = false  # Optional
    }
  ]

  tags = {
    Name = "Jenkins SG"
  }
}


# Create the sonarqube security groups



 resource "aws_security_group" "sonarqube_sg" {
name        = "sonarqube SG"
  description = "allow ports 9000 and 22"
  vpc_id      = aws_vpc.production_vpc.id

  ingress = [
    {
      description = "sonarqube"
      from_port   = var.sonarqube_port
      to_port     = var.sonarqube_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []  # Optional: Add if you need to allow IPv6 addresses
        prefix_list_ids  = []  # Optional: Add if you need to use AWS prefix lists
        security_groups  = []  # Optional: Add if you need to allow other security groups
        self             = false  # Optional: Set to true if you need to allow traffic from itself
    },
    {
      description = "SSH"
      from_port   = var.SSH_port
      to_port     = var.SSH_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []  # Optional: Add if you need to allow IPv6 addresses
        prefix_list_ids  = []  # Optional: Add if you need to use AWS prefix lists
        security_groups  = []  # Optional: Add if you need to allow other security groups
        self             = false  # Optional: Set to true if you need to allow traffic from itself
    }
  ]

  egress = [
    { description = "allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
       ipv6_cidr_blocks = []  # Optional: Add if you need to allow IPv6 addresses
       prefix_list_ids  = []  # Optional: Add if you need to use AWS prefix lists
       security_groups  = []  # Optional: Add if you need to allow other security groups
       self             = false  # Optional: Set to true if you need to allow traffic from itself
    }
  ]

  tags = {
    Name = "Sonarqube SG"
  }
}


#ansible security group


resource "aws_security_group" "ansible_sg" {
  name        = "ansible SG"
  description = "allow port 22"
  vpc_id      = aws_vpc.production_vpc.id

  ingress = [
    {
      description = "SSH"
      from_port   = var.SSH_port
      to_port     = var.SSH_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []  # Optional: Add if you need to allow IPv6 addresses
        prefix_list_ids  = []  # Optional: Add if you need to use AWS prefix lists
        security_groups  = []  # Optional: Add if you need to allow other security groups
        self             = false  # Optional: Set to true if you need to allow traffic from itself
    }
  ]

  egress = [
    { description = "allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []  # Optional: Add if you need to allow IPv6 addresses
        prefix_list_ids  = []  # Optional: Add if you need to use AWS prefix lists
        security_groups  = []  # Optional: Add if you need to allow other security groups
        self             = false  # Optional: Set to true if you need to allow traffic from itself
    }
  ]

  tags = {
    Name = "Ansible SG"
  }
}



#  Graphana Security Group



resource "aws_security_group" "grafana_sg" {
  name        = "grafana SG"
  description = "allow port 3000 and 22"
  vpc_id      = aws_vpc.production_vpc.id

  ingress = [
    {
      description = "Grafana"
      from_port   = var.grafana_port
      to_port     = var.grafana_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []  # Optional: Add if you need to allow IPv6 addresses
        prefix_list_ids  = []  # Optional: Add if you need to use AWS prefix lists
        security_groups  = []  # Optional: Add if you need to allow other security groups
        self             = false  # Optional: Set to true if you need to allow traffic from itself
    },
    {
      description = "SSH"
      from_port   = var.SSH_port
      to_port     = var.SSH_port
      protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"] 
        ipv6_cidr_blocks = []  # Optional: Add if you need to allow IPv6 addresses
        prefix_list_ids  = []  # Optional: Add if you need to use AWS prefix lists
        security_groups  = []  # Optional: Add if you need to allow other security groups
        self             = false  # Optional: Set to true if you need to allow traffic from itself
    }
   ]

  egress = [
    { description = "allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []  # Optional: Add if you need to allow IPv6 addresses
        prefix_list_ids  = []  # Optional: Add if you need to use AWS prefix lists
        security_groups  = []  # Optional: Add if you need to allow other security groups
        self             = false  # Optional: Set to true if you need to allow traffic from itself
    }
  ]

  tags = {
    Name = "Grafana SG"
  }
}



# security group for Application security group




resource "aws_security_group" "application_sg" {
  name        = "Application SG"
  description = "allow ports 80 and 22"
  vpc_id      = aws_vpc.production_vpc.id

  ingress = [
    {
      description = "Application"
      from_port   = var.http_port
      to_port     = var.http_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []  # Optional: Add if you need to allow IPv6 addresses
        prefix_list_ids  = []  # Optional: Add if you need to use AWS prefix lists
        security_groups  = []  # Optional: Add if you need to allow other security groups
        self             = false  # Optional: Set to true if you need to allow traffic from itself
    },
    {
      description = "SSH"
      from_port   = var.SSH_port
      to_port     = var.SSH_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] 
        ipv6_cidr_blocks = []  # Optional: Add if you need to allow IPv6 addresses
        prefix_list_ids  = []  # Optional: Add if you need to use AWS prefix lists
        security_groups  = []  # Optional: Add if you need to allow other security groups
        self             = false  # Optional: Set to true if you need to allow traffic from itself
    }
  ]

  egress = [
    { description = "allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []  # Optional: Add if you need to allow IPv6 addresses
        prefix_list_ids  = []  # Optional: Add if you need to use AWS prefix lists
        security_groups  = []  # Optional: Add if you need to allow other security groups
        self             = false  # Optional: Set to true if you need to allow traffic from itself
    }
  ]

  tags = {
    Name = "Application SG"
  }
}



#  Load Balancer Security Group 




resource "aws_security_group" "loadbalancer_sg" {
  name        = "Loadbalancer SG"
  description = "allow port 80"
  vpc_id      = aws_vpc.production_vpc.id

  ingress = [
    {
      description = "Loadbalancer"
      from_port   = var.http_port
      to_port     = var.http_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []  # Optional: Add if you need to allow IPv6 addresses
        prefix_list_ids  = []  # Optional: Add if you need to use AWS prefix lists
        security_groups  = []  # Optional: Add if you need to allow other security groups
        self             = false  # Optional: Set to true if you need to allow traffic from itself
    }
  ]

  egress = [
    { description = "allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []  # Optional: Add if you need to allow IPv6 addresses
        prefix_list_ids  = []  # Optional: Add if you need to use AWS prefix lists
        security_groups  = []  # Optional: Add if you need to allow other security groups
        self             = false  # Optional: Set to true if you need to allow traffic from itself
    }
  ]

  tags = {
    Name = "LoadBalancer SG"
  }
}
