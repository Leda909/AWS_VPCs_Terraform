# Virtual Private Cloud (VPC)

A **Virtual Private Cloud (VPC)** is a logically isolated section of the Cloud where you can launch cloud resources in a virtual network that you define. Think of it as your own private data center within cloud, but with all the scalability and flexibility of cloud infrastructure.

You have complete control over your virtual networking environment, including:
* Selection of your own IP address range
* Creation of subnets
* Configuration of route tables and network gateways
* Security settings at multiple layers

<img src="../teory_of_VPC/images/VPC_1.png" width="70%" alt="What is VPC" style="margin: 20px 100px">

**Proffessional def.**:
A VPC is a software-defined network within Cloud that provides isolated network infrastructure. It enables organizations to architect multi-tier applications with granular control over network topology, IP addressing (IPv4 and IPv6), routing policies, and security controls through Security Groups and Network ACLs. VPCs support hybrid cloud architectures via VPN and Direct Connect, enable service-to-service communication through VPC endpoints, and maintain network isolation through logical segmentation across availability zones for high availability and fault tolerance.

### Example of Node App EC2 connected to MongoDB EC2 (in both case use IAM EC2)

<img src="../teory_of_VPC/images/VPC_2.png" alt="Image 1 Description" style="width: 150%;">

#### **Why This Architecture Works?**

1. Layered Security (Defense in Depth)

    * Even if someone hacks the load balancer, they can't reach the database
    * Each layer only trusts specific previous layers

2. Principle of Least Privilege
    
    * Node.js can ONLY talk to MongoDB (not the internet)
    * MongoDB can ONLY talk to Node.js (not even the internet)

3. High Availability
    
    * If you deploy across 2-3 Availability Zones, your app stays up even if one data center fails

4. Scalability
    
    * Add more Node.js instances behind the load balancer as traffic grows
    * Database can be scaled independently

### Why use, create or customise them?

**Key Reasons to Customize VPCs:**

1. Security & Isolation
    * Create isolated environments for different applications or teams
    * Implement defense-in-depth security architecture
    * Meet compliance requirements (HIPAA, PCI-DSS, etc.)

2. Network Control
    * Define your own IP address space using CIDR blocks
    * Control inbound and outbound traffic at subnet and instance levels
    * Implement custom routing strategies
    
3. Multi-tier Architecture
    * Separate public-facing web servers from private database servers
    * Implement DMZ (demilitarized zone) patterns
    * Create secure backend services without internet exposure

4. Hybrid Cloud Integration
    * Connect on-premises data centers to AWS via VPN or Direct Connect
    * Extend existing corporate networks into the cloud
    * Enable seamless migration strategies

5. Cost Optimization
    * Use VPC endpoints to avoid data transfer charges for AWS services
    * Implement NAT gateways only where needed
    * Optimize network architecture for traffic patterns

### Default VPC

Every AWS account comes with a default VPC in each region. Here's what it includes:

<img src="../teory_of_VPC/images/VPC_default_5.png" width="40%" alt="Default VPC" style="margin: 20px">

# The core components:

## a) SUBNET

A **subnet** is a segmented range of IP addresses within a VPC. Subnets allow you to partition your VPC's IP address space and place resources in different network segments. Each subnet resides entirely within one Availability Zone and can be designated as public (internet-accessible) or private (isolated).

<img src="../teory_of_VPC/images/subnet.png" width="80%" alt="VPC Subnets">

Subnets are like different floors in a building, in which the ground floor is the public subnet with doors to the street, so visitors can come in. Then the basement floor would be a private subnet has no street doors, it's only for people already inside the building. You put your web servers on the ground floor and your secret database in the basement.

##### Key Points:
* Public Subnet:<br>Has a route to Internet Gateway, resources get public IPs
* Private Subnet:<br>No direct internet access, resources only have private IPs
* One AZ:<br>Each subnet lives in exactly one Availability Zone
* CIDR Block:<br>Each subnet has its own IP range (e.g., 10.0.1.0/24)

## b) INTERNET GATWAY 

An **Internet Gateway (IGW)** is a horizontally scaled, redundant, and highly available VPC component that allows communication between your VPC and the internet. It performs Network Address Translation (NAT) for instances with public IPv4 addresses and enables both inbound and outbound internet traffic.

<img src="../teory_of_VPC/images/IGW.png" width="80%" alt="Internet GateWay">

The Internet Gateway is like the main door to your house (VPC)! Without this door, you're stuck inside with no way to talk to the outside world!

##### Key Points:
* One per VPC:<br> You can only attach one IGW to a VPC
* Bidirectional:<br> Allows both inbound and outbound traffic
* Scalable:<br> Automatically scales, no bandwidth constraints
* Free:<br> No charge for the IGW itself (only data transfer)

## c) ROUTE TABLES

A **Route Tables** contains a set of rules (routes) that determine where network traffic from your subnet or gateway is directed. Each route specifies a destination CIDR block and a target (e.g., Internet Gateway, NAT Gateway, VPC Peering connection). Every subnet must be associated with a route table.

<img src="../teory_of_VPC/images/RT.png" width="60%" alt="Route Tables">

A Route Table is like a GPS or map with directions! When a letter (data packet) needs to go somewhere, it checks the route table: "Should I go to the neighbor's house (local VPC)? Or through the front door to the mailbox (Internet Gateway)? </div>
       
##### Key Points:
* One per VPC:<br>You can only attach one IGW to a VPC
* Bidirectional:<br> Allows both inbound and outbound traffic
* Scalable:<br>Automatically scales, no bandwidth constraints
* Free:<br>No charge for the IGW itself (only data transfer)

## d) A NAT (Network Address Translation) Gateway / NAT INSTANCE

A **NAT (Network Address Translation) Gateway** enables instances in private subnets to initiate outbound connections to the internet while preventing inbound connections initiated from the internet. It performs port address translation, allowing multiple private instances to share a single public IP address for outbound traffic.

<img src="../teory_of_VPC/images/NAT.png" width="80%" alt="Network Address Translation">

NAT Gateway helps to connect for your private subnet with the internet - eg. download updates - however, it not allows net to connect to private subnet.

##### Key Points:

* One-way traffic:<br>Outbound only, no inbound connections
* Located in public subnet:<br>Needs public IP to reach internet
* Managed service:<br> AWS-managed (NAT Gateway) vs self-managed (NAT Instance)
* High availability:<br> Use one per AZ for redundancy



IP addresses:
- Public vs Private IP addresses
- IPv4 vs IPv6
 - CIDR blocks
 - Subnet masks
- Reserved IP ranges
- What is NAT?

Subnets:
- Public and Private subnets
- How do AZs relate to subnets?

Gateways:
- NAT Gateways vs Internet Gateways
- How do public subnets access the internet?
- Why do private subnets need NAT?
- Are there cost differences?
- Different architectures?

Route Tables:
- What does a "default" route table look like?
- Local routing
- 0.0.0.0/0 routing
- Routes to NAT gateway vs internet gateway
- How do RT association work?

SGs and NACLs:
- What are ports?
- Inbound vs Outbound rules
- Stateful vs stateless
- SG referencing
- Common SG architectures

Bonus:
- DNS
- Route53
- Different VPC designs

Reminders:
- Use images
- Make/link diagrams where possible
- Keep things fairly concise
- Guide should be usable by others
- Be ready to present your work tomorrow

If you finish the VPC documentation task, or get bored, you  could try to improve the security of our app and database deployment WITHOUT making/creating a VPC.

Some ideas:
- Disable public IP for the db instance
- Make SG rules only allow specific IP address for the db connection

If you do these or find other ways to improve security then please be open to sharing them tomorrow morning.


https://blog.cloudcraft.co/