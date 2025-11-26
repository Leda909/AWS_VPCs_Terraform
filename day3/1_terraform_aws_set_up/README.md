## 1. Install terraform on Windows

1. Download Terraform zip from the offical HashiCorp website install Terraform page:<br>
[HashiCorp install Terraform](https://developer.hashicorp.com/terraform/install)

2. Follow the Installation Guide from following guide:<br>
[SpaceLift Guide to install Terraform](https://spacelift.io/blog/how-to-install-terraform)

Run in your `bash` terminal to check installation by version: `terraform --version` 

For upgrade just redo the installation process with the latesst terraform package.

## 2. Install AWS on Windows

Install AWS for Windows in your terminal:<br>
`curl "https://awscli.amazonaws.com/AWSCLIV2.msi" -o "AWSCLIV2.msi"
msiexec.exe /i AWSCLIV2.msi /qn`

Check in your terminal that `aws` installed on your pc:<br>`aws --version`

## 3. Terraform setup/config

In order for our local Terraform to be able to connect to our AWS account via AWSCLI, we need to add our ACCESS and SECRET keys.

These credentials are EXTREMELY SENSITIVE! DO NOT EXPOSE THEM IN ANY WAY!

##### There are two ways to set things up:
- Add them to aws config and credentials files
- Add them as environment variables

It is recommended to add them as credentials. See the guide below:

AWS uses two files stored in your home directory to authenticate via AWS CLI, these two files are:
~/.aws/credentials
~/.aws/config

The files store your access keys, default region and profiles (optional).

We can either set these up manually, or install awscli and have it do it for us.. Let's try installing awscli.

1. Get an IAM ACCESS KEYS from AWS

Then run `aws configure` in your terminal

```
AWS Access Key ID [****************YKSZ]: <YOUR_KEY_ID>
AWS Secret Access Key [****************zKFc]: <YOUR_SECRET_KEY>
Default region name [None]: eu-west-1
Default output format [None]: json
```

It will create a config file in your aws folder.

To check your connection to aws via terminal:<br>
`aws sts get-caller-identity`

Response:<br>
```
{
    "UserId": "AI.......",
    "Account": "13.......",
    "Arn": "arn:aws:iam::135928476890:user/<your-user-name>"
}

```

## 4. Explain Terraform tf.state file

When you run terraform in your machine it will automaticaly create a tf.state file

### What is the Terraform State File?

The **terraform.tfstate** file is a JSON-formatted file that Terraform automatically creates and maintains to keep track of the current state of your infrastructure.<br> 
It serves as Terraform's "memory" or "source of truth" about:
* What resources exist in your actual cloud infrastructure
* The current configuration of those resources (IDs, attributes, metadata)
* Dependencies between resources (which resources rely on others)
* Mappings between your Terraform configuration code and real-world infrastructure

Key Characteristics:
- **Format:** JSON structure containing resource metadata
- **Location:** By default stored locally as terraform.tfstate
- **Updates:** Modified after every terraform apply operation
- **Backup:** Terraform creates terraform.tfstate.backup before updates

### Why is the State File So Sensitive?

The Terraform state file is highly sensitive for multiple critical reasons:
1. **Contains Secrets and Sensitive Data**
    * Database passwords
    * API keys and tokens
    * Private IP addresses
    * SSH keys
    * Connection strings
    * Certificate data
    * Stored in PLAIN TEXT within the JSON structure
2. **Complete Infrastructure Blueprint**
    * Reveals your entire infrastructure architecture
    * Shows network topology and security configurations
    * Exposes resource naming conventions
    * Contains internal IDs and identifiers
3. Security Attack Surface<br>
   If compromised, attackers gain:
    * Full knowledge of your infrastructure layout
    * Access credentials to resources
    * Ability to craft targeted attacks
    * Information for lateral movement
4. Integrity Critical
    * Corruption or manipulation can:
    * Cause Terraform to destroy resources unintentionally
    * Create infrastructure drift
    * Lead to complete infrastructure failure

### Working with Terraform state files in teams introduces significant challenges

* Challenge 1: **State Locking Conflicts**
    * Problem: Multiple team members running terraform apply simultaneously can corrupt the state
    * Result: Race conditions, inconsistent infrastructure, data loss
* Challenge 2: **State File Synchronization**
    * Problem: **Each developer needs access to the same, current version of state**
    * Risk: Working with outdated state leads to:
        * Duplicate resource creation
        * Unintended resource deletion
        * Configuration drift
* Challenge 3: **Version Control Concerns**
    * Problem: Storing state in Git creates issues:
        * Merge conflicts are difficult to resolve
        * Secrets exposed in version history
        * Large file size impacts repository performance
        * No built-in locking mechanism
* Challenge 4: Access Control
    * Problem: State contains sensitive data but must be shared
    * Risk: Balancing security (who can access) with functionality (who needs access)
* Challenge 5: Backup and Recovery
    * Problem: State file loss = loss of infrastructure management capability
    * Risk: Without state, Terraform can't manage existing resources

<br><br>
<img src="../1_terraform_aws_set_up/images/remote_tf.state.png" width="50%" alt="Remote tf.state file">

### Best Practices To address these Collaborative Work Challenges, teams should:

* Use remote state backends (S3, Azure Blob, GCS, Terraform Cloud)

* Enable state locking (DynamoDB for S3, native for Terraform Cloud)

* Implement encryption at rest and in transit

* Use partial configuration to avoid committing backend credentials

* Implement RBAC (Role-Based Access Control) for state access

* Regular state backups with versioning enabled

* Never commit state files to version control

* Use .gitignore to exclude *.tfstate and *.tfstate.backup

