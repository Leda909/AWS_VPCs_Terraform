# Create VPC on AWS

## 1. Create VPC

Go to AWS VPC page and press create VPC

naming convention: `se-adel-2tier-vpc`  (2tier because --> App + MongoDB )
   
Follow the set up as image shows (tag are automat based on vpc name)

Set Up IPv4 CIDR: `10.0.0.0/16`

<img src="../1_create_VPC/images/create_vpc.png" width="60%" alt="Create VPC">

## 2. Create Subnet to VPC

Go to VPC Subnet section and create subnet to your VPC

Follow inst. ac image

Assing to the created VPC `se-adel-2tier-vpc`

To keep it simple, now we just picked up one availability zone to each subnet:<br>
public-subnet: `eu-west-1a`<br>
private-subnet: `eu-west-1b`

<img src="../1_create_VPC/images/create_subnet_vpc_1.png" width="60%" alt="Create VPC">

Create *Public Subnet*

Press Add new tag, and follow inst. ac image

<img src="../1_create_VPC/images/create_subnet_vpc_2.png" width="60%" alt="Create VPC">

## 3. Create Internet Gateway to VPC

Follow inst ac image

<img src="../1_create_VPC/images/create_internet_gateway_vpc_1.png" width="60%" alt="Create VPC">

Attach the created `se-adel-2tier-vpc` to the Internet Gateway (see image)

<img src="../1_create_VPC/images/attach_internet_gateway_to_vpc_2.png" width="60%" alt="Create VPC">

## 4. Create Route tables to VPC

1. Create Route Table (Follow inst. ac image)

naming convention: `se-adel-2tier-vpc-rt`

<img src="../1_create_VPC/images/create_route_table_vpc_1.png" width="60%" alt="Create VPC">

Press create Route Table ---> Navigate / Press on the created new Route Table

2. a) *Attach* the public subnet to your new Route table

Navigate to edit subnet association button part - (follow inst ac image)

<img src="../1_create_VPC/images/edit_subnet_association_1.png" width="60%" alt="Create VPC">

Attach the *public subnet* to the Route

<img src="../1_create_VPC/images/edit_subnet_association_to_route_tb_vpc_2.png" width="60%" alt="Create VPC">

2. b) Add *Internet GateWay* to your new Route Table
(Follow inst ac image)

<img src="../1_create_VPC/images/edit_route_vpc_1.png" width="60%" alt="Create VPC">

<img src="../1_create_VPC/images/edit_route_internet_gateway_2.png" width="60%" alt="Create VPC">

<img src="../1_create_VPC/images/final_route_tables.png" width="60%" alt="Create VPC">

## 5. See the *Resource Map of the VPC* - Ready, Connected to the right subnets and routers

<img src="../1_create_VPC/images/final_vpc_resource_map.png" width="60%" alt="Create VPC">