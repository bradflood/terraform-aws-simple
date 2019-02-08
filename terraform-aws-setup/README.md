be aware of the aws configuration profile being used
aws configure list

I have two profiles, one for keyhole-dev and one for my personal account. Here is the contents of the ~/.aws/credentials file
[default]
aws_access_key_id = [removed]
aws_secret_access_key = [removed]
[keyhole-dev]
aws_access_key_id = [removed]
aws_secret_access_key = [removed]

set the profile:
export AWS_PROFILE=keyhole-dev

terraform init
terraform plan -var 'bucket_name=bwflood-terraform-state'
terraform apply -var 'bucket_name=bwflood-terraform-state'


terraform remote config -backend = s3 -backend-config =" bucket =bwflood-terraform-state-dev" -backend-config =" key = global/s3/ terraform.tfstate" \ -backend-config =" region = us-east-1" \ -backend-config =" encrypt = true"


references
https://medium.com/@itsmattburgess/why-you-should-be-using-remote-state-in-terraform-2fe5d0f830e8