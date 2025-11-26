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
    "UserId": "AIDA.....",
    "Account": "1359.....",
    "Arn": "arn:aws:iam::135928476890:user/se-adel"
}

```