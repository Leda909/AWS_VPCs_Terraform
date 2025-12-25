cd into the right folder: *2_make_EC2*

Then run in your terminal:
Initalize terraform:<br>
`terraform init`

Get *AMI ID* to your EC2 instance

When resource of aws_instance done, run in terminal:
terraform plan<br>
`terraform plan`

Next command:
To apply the terraform plan<br>
`terraform apply`

When finish destroy<br>
`terraform destroy`

IMPORTANT! write every terraform state files in the .gitignore to not push online!