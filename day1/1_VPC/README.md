# Virtual Private Cloud (VPC)

A **Virtual Private Cloud (VPC)** is a logically isolated section of the Cloud where you can launch cloud resources in a virtual network that you define. Think of it as your own private data center within cloud, but with all the scalability and flexibility of cloud infrastructure.

You have complete control over your virtual networking environment, including:
* Selection of your own IP address range
* Creation of subnets
* Configuration of route tables and network gateways
* Security settings at multiple layers

<img src="../1
_VPC/images/VPC_1.png" width="70%" alt="What is VPC" style="margin: 20px 100px">

**Proffessional def.**:
A VPC is a software-defined network within Cloud that provides isolated network infrastructure. It enables organizations to architect multi-tier applications with granular control over network topology, IP addressing (IPv4 and IPv6), routing policies, and security controls through Security Groups and Network ACLs. VPCs support hybrid cloud architectures via VPN and Direct Connect, enable service-to-service communication through VPC endpoints, and maintain network isolation through logical segmentation across availability zones for high availability and fault tolerance.

### Example of Node App EC2 connected to MongoDB EC2 (in both case use IAM EC2)

<img src="../1
_VPC/images/VPC_2.png" alt="Image 1 Description" style="width: 150%;">

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

<img src="../1
_VPC/images/VPC_default_5.png" width="40%" alt="Default VPC" style="margin: 20px">

# The core components:

## SUBNET

A **subnet** is a segmented range of IP addresses within a VPC. Subnets allow you to partition your VPC's IP address space and place resources in different network segments. Each subnet resides entirely within one Availability Zone and can be designated as public (internet-accessible) or private (isolated).

<img src="../1
_VPC/images/subnet.png" width="80%" alt="VPC Subnets">

Subnets are like different floors in a building, in which the ground floor is the public subnet with doors to the street, so visitors can come in. Then the basement floor would be a private subnet has no street doors, it's only for people already inside the building. You put your web servers on the ground floor and your secret database in the basement.

##### Key Points:
* Public Subnet:<br>Has a route to Internet Gateway, resources get public IPs
* Private Subnet:<br>No direct internet access, resources only have private IPs
* One AZ:<br>Each subnet lives in exactly one Availability Zone
* CIDR Block:<br>Each subnet has its own IP range (e.g., 10.0.1.0/24)

## INTERNET GATWAY 

An **Internet Gateway (IGW)** is a horizontally scaled, redundant, and highly available VPC component that allows communication between your VPC and the internet. It performs Network Address Translation (NAT) for instances with public IPv4 addresses and enables both inbound and outbound internet traffic.

<img src="../1
_VPC/images/IGW.png" width="80%" alt="Internet GateWay">

The Internet Gateway is like the main door to your house (VPC)! Without this door, you're stuck inside with no way to talk to the outside world!

##### Key Points:
* One per VPC:<br> You can only attach one IGW to a VPC
* Bidirectional:<br> Allows both inbound and outbound traffic
* Scalable:<br> Automatically scales, no bandwidth constraints
* Free:<br> No charge for the IGW itself (only data transfer)

## ROUTE TABLES

A **Route Tables** contains a set of rules (routes) that determine where network traffic from your subnet or gateway is directed. Each route specifies a destination CIDR block and a target (e.g., Internet Gateway, NAT Gateway, VPC Peering connection). Every subnet must be associated with a route table.

<img src="../1
_VPC/images/RT.png" width="70%" alt="Route Tables">

A Route Table is like a GPS or map with directions! When a letter (data packet) needs to go somewhere, it checks the route table: "Should I go to the neighbor's house (local VPC)? Or through the front door to the mailbox (Internet Gateway)? </div>
       
##### Key Points:
* One per VPC:<br>You can only attach one IGW to a VPC
* Bidirectional:<br> Allows both inbound and outbound traffic
* Scalable:<br>Automatically scales, no bandwidth constraints
* Free:<br>No charge for the IGW itself (only data transfer)

## A NAT (Network Address Translation) Gateway / NAT INSTANCE

A **NAT (Network Address Translation) Gateway** enables instances in private subnets to initiate outbound connections to the internet while preventing inbound connections initiated from the internet. It performs port address translation, allowing multiple private instances to share a single public IP address for outbound traffic.

<img src="../1
_VPC/images/NAT.png" width="80%" alt="Network Address Translation">

NAT Gateway helps to connect for your private subnet with the (global)internet - eg. download updates - however, it not allows net to connect to private subnet. For instance, it's like a *mailslot* on your bedroom, you can write a letter and post to the world, however the postman can NOT push letter into your room. only works one way! This keeps your bedroom private and safe!

##### Key Points:

* One-way traffic:<br>Outbound only, no inbound connections
* Located in public subnet:<br>Needs public IP to reach internet
* Managed service:<br> AWS-managed (NAT Gateway) vs self-managed (NAT Instance)
* High availability:<br> Use one per AZ for redundancy

## SECURITY GROUPS

A **Security Group** acts as a virtual firewall at the instance level (specifically at the Elastic Network Interface). It controls inbound and outbound traffic using allow rules only. Security Groups are stateful - if you allow an inbound request, the response is automatically allowed regardless of outbound rules.<br>
Security Groups are like a whitelist - everything is denied by default, and you explicitly allow what's needed. They're **stateful**, meaning if I allow incoming traffic on port 443, the response traffic is automatically allowed without needing an outbound rule

<img src="../1
_VPC/images/security_groups.png" width="80%" alt="Network Address Translation">

It's like a personal bodyguard who knows the list of allowed people that can come in. If (allowed IP) welcome and lets them AND remembers them, so when they leave later, they don't need to be checked again. However, strainger can not get in.

##### Key Points:

* Instance-level: <br>Protects individual EC2 instances (ENIs)
* Stateful: <br>Return traffic automatically allowed
* Allow rules only: <br>You can only specify ALLOW rules (no DENY)
* Multiple SGs: <br>An instance can have multiple security groups

## NETWORK ACLs (NACLs)

**Network Access Control Lists (NACLs)** are stateless firewalls that operate at the subnet level. They evaluate rules in numerical order and support both ALLOW and DENY rules. Unlike Security Groups, NACLs are **stateless** - return traffic must be explicitly allowed.

<img src="../1
_VPC/images/NALs.png" width="90%" alt="Network Address Translation">

NACLs are like a fence around your entire neighborhood (subnet)! The fence has a gatekeeper who checks EVERY person going in AND out with a rulebook. Even if someone was let in earlier, they need to be checked AGAIN when leaving. The gatekeeper follows rules in order

#### Key Points

* Subnet-level: <br>One NACL per subnet, protects all instances in subnet
* Stateless: <br>Must explicitly allow return traffic
* Numbered rules: <br>Evaluated in order (lowest number first)
* ALLOW & DENY: <br>Can explicitly deny traffic

### Security Groups VS NALs
<img src="../1
_VPC/images/security_groups_vs_NALs.png" width="50%" alt="Network Address Translation">

##### Use Case
Use NACLs as a second layer of defense. Block entire IP ranges at the subnet level if they're known malicious sources, while Security Groups handle fine-grained instance-level control.

## VPC ENDPOINTS

**VPC Endpoints** enable private connectivity between your VPC and supported AWS services without requiring an Internet Gateway, NAT device, VPN connection, or AWS Direct Connect. Traffic between your VPC and AWS services stays within the AWS network, improving security and reducing data transfer costs.

<img src="../1
_VPC/images/vpc-endpoints.png" width="40%" alt="Network Address Translation">

Imagine you need milk from the store (AWS service like S3). WITHOUT a VPC Endpoint, you have to walk through your front door, down the street, to the store, and back - that's a long trip! WITH a VPC Endpoint, it's like having a secret tunnel directly from your basement to the store's back room - much faster, safer, and you don't need to go outside at all!

#### Key Points:

* Private connection: <br>Traffic never leaves AWS network
* No internet needed: <br>No IGW or NAT Gateway required
* Cost savings: <br>Avoid NAT Gateway data processing charges
* Two types: <br>Gateway Endpoints (S3, DynamoDB) and Interface Endpoints (most others)

#### Types of VPC Endpoints:
1. Gateway Endpoints (Free!):
    * Amazon S3
    * Amazon DynamoDB
    * Uses route table entries
2. Interface Endpoints (~$7/month per endpoint):
    * Most AWS services (EC2, Lambda, SNS, SQS, etc.)
    * Uses Elastic Network Interface (ENI)
    * Powered by AWS PrivateLink
3. Cost Savings Example<br>
    WITHOUT VPC Endpoint:
    <br>Private instance → NAT Gateway → Internet → S3
    <br>NAT Gateway cost: $0.045/hour + $0.045/GB processed
    <br>Monthly (100GB): ~$32 + $4.50 = $36.50<br>
    WITH VPC Endpoint:
    <br>Private instance → VPC Endpoint → S3
    <br>Endpoint cost: $0 (Gateway Endpoint for S3)
    <br>Monthly (100GB): $0
    SAVINGS: $36.50/month!

## VPC PEERING

**VPC Peering** is a networking connection between two VPCs that enables routing traffic between them using private IPv4 or IPv6 addresses. Instances in either VPC can communicate as if they're within the same network. VPC Peering connections are not transitive; you must establish a direct peering connection between each pair of VPCs.

<img src="../1
_VPC/images/vpc-peering.png" width="40%" alt="Network Address Translation">

VPC Peering is like having two houses connected by a private bridge! Instead of going through the street (internet) to visit your friend's house (another VPC), you can walk directly across your private bridge. But here's the catch: if House A has a bridge to House B, and House B has a bridge to House C, people in House A CAN'T walk through House B to get to House C - each pair needs their own bridge!

#### Key Points

* Direct connection: <br>One-to-one private connection between VPCs
* Not transitive: <br>A↔B, B↔C does NOT mean A↔C
* Same or different regions: <br>Works cross-region
* No overlapping CIDRs: <br>VPCs must have different IP ranges

#### Use Cases:

* 2-3 VPCs: Simple backup or dev/prod separation
* Different accounts: Connect VPCs across AWS accounts
* Low cost: No data charges within same region

###### Setup Steps<br>
1. Create Peering Connection request from VPC A
2. Accept Peering Connection in VPC B
3. Update Route Table in VPC A: 10.1.0.0/16 → pcx-12345
4. Update Route Table in VPC B: 10.0.0.0/16 → pcx-12345
5. Update Security Groups to allow cross-VPC traffic

###### Non-Transitive Example<br>
<br>VPC A (10.0.0.0/16) ↔ VPC B (10.1.0.0/16)
<br>VPC B (10.1.0.0/16) ↔ VPC C (10.2.0.0/16)
<br>VPC A CANNOT reach VPC C through VPC B

## VPC FLOW LOGS

**VPC Flow Logs** capture information about IP traffic going to and from network interfaces in your VPC. Flow log data is published to CloudWatch Logs, Amazon S3, or Amazon Kinesis Data Firehose. They're essential for network monitoring, troubleshooting connectivity issues, security analysis, and compliance auditing.

<img src="../1
_VPC/images/vpc-flow-logs.png" width="40%" alt="Network Address Translation">

VPC Flow Logs are like a security camera recording everything that happens at your house! It writes down: "At 2pm, a car with license plate XYZ tried to enter the driveway - ALLOWED. At 3pm, a stranger tried the door - BLOCKED." Later, if something goes wrong, you can watch the recording to see exactly what happened!

#### Key Points

* Traffic capture: <br>Records metadata about traffic (not content)
* Three levels: <br>VPC-level, Subnet-level, or ENI-level
* Three destinations: <br>CloudWatch Logs, S3, or Kinesis
* Direction filter: <br>Capture ALL, ACCEPT only, or REJECT only

#### Common Use Cases
1. Security Analysis
-- Find all rejected connections (CloudWatch Insights)
fields @timestamp, srcaddr, dstaddr, dstport, action
| filter action = "REJECT"
| sort @timestamp desc
2. Troubleshooting
Q: Why can't my instance connect to the database?
A: Check flow logs:
   - REJECT at security group? → Fix security group rules
   - ACCEPT but no response? → Check application/routing
3. Compliance
    - Prove all database connections are internal only
    - Audit which IPs accessed sensitive resources
    - Demonstrate network segmentation
4. Cost Optimization
    - Identify heavy traffic sources
    - Find unexpected internet traffic
    - Optimize NAT Gateway usage


## CIDR BLOCKS

**CIDR (Classless Inter-Domain Routing)** notation is a method for specifying IP address ranges. The format IP/prefix indicates the network address and the number of significant bits. For example, 10.0.0.0/16 means the first 16 bits are fixed (network), leaving 16 bits for hosts (2^16 = 65,536 addresses).

<img src="../1
_VPC/images/cidr-blocks.png" width="40%" alt="Network Address Translation">

CIDR is like a phone area code! The number 555-0000/3 means "all phone numbers that start with 555." The /3 tells you how many numbers at the start are fixed. In the VPC world, 10.0.0.0/16 means "all IP addresses that start with 10.0" - that gives you 65,536 different addresses to use for your computers! 
Computers use the binary system, every free bit (position) represents two possibilities (0 or 1). If you have 16 free bits, then the number of combinations is $2^{16}$ = 65 536

#### Key Points

* Format: IP-address/prefix-length (e.g., 10.0.0.0/16)
* Prefix length: Number of fixed bits (higher number = smaller range)
* Calculation: Remaining bits = number of IPs ($2^{remaining bits}$)
* RFC 1918: Private IP ranges: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16


