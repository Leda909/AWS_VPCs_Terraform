vpc_cidrs = "<your_vpc_cidr"

public_subnet_cidrs =  ["<your_first_public_subnet_cidr>", "<your_second_public_subnet_cidr>", "<your_third_public_subnet_cidr>"]
private_subnet_cidrs = ["<your_first_private_subnet_cidr>", "<your_second_private_subnet_cidr>", "<your_third_private_subnet_cidr>"]

rt_cidrs = "<your_route_table_cidr>"
ssh_cidr_block = "<your_ssh_cidr>"

avz_public = ["<your_first_public_availability_zone>", "<your_second_public_availability_zone>", "<your_third_public_availability_zone>"]
avz_private = ["<your_first_private_availability_zone>", "<your_second_private_availability_zone>", "<your_third_private_availability_zone>"]

mongodb_id = "<your_mongodb_ami_id_here>" # <--- copy and paste your existing MongoDB AMI ID
mongodb_instance_type ="<t3.micro>"
mongodb_key_pair = "<your_mongodb_key_pair_here>"

app_id = "<your_app_ami_id_here>" # <--- copy and paste your existing App AMI ID
app_instance_type ="<your_app_instance_type_here>"
app_key_pair = "<your_app_key_pair_here>"