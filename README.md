##########################################

Please be advised that I have structured the entirety of the code within a singular file named "main.tf." This strategic arrangement is intended to facilitate a streamlined evaluation process, eliminating the need to navigate through other files.

In an alternate scenario, it is considered a recommended practice to maintain specific elements within designated files for better organization:

Security groups are conventionally managed within a file named "sg.tf."
IAM roles are managed in a dedicated file named "iam.tf."
The principal codebase is reserved for "main.tf."

Given the nature of this assignment, and its purpose to remain solely for assessment rather than deployment, I have refrained from introducing variable integration. Otherwise, the best practices for examples are using variables.tf and terraform.tfvars.

#############################################

I'm providing you the access to this repo to evaluate the assignment. Below is how you can test the application:

Prerequisites:

1. Preparing the AWS S3 Bucket:
   
    a. Inside Infrastructure folder go to backend.tf and copy the s3 bucket name. Please create the bucket with this name.
   
    b. Inside application folder go to backend.tf and copy the s3 bucket name. Please create the bucket with this name.
   
2. Please have the secret key and the secret access key of the IAM Admin user handy. You also need the AWS account Number as well.

How to Test:

1. Please click Settings and then in left side pane you will see, Secrets and Variables. Please click on it and it will open three options.
   
2. Please click Actions out of these three options.
   
3. It will pop up three Secrets.
   
5. 
    a. AWS_ACCESS_KEY_ID
   
    b. AWS_SECRET_ACCESS_KEY
   
    c. AWS_ACCOUNT_ID
   
Please fill in this information and the secrets will remain encrypted throughout the pipeline. No one could actually see these secrets.

4. Once done, Please Click Actions, which is just beside the "Pull Requests" button. Once you click "Actions" you will see two workflows on the left hand side.

a. Deploy Infrastructure with Terraform

b. Deploy Application.

Please first click "Deploy Infrastructure with Terraform" and you will see "Run workflow" button on the left hand side corner. Click this button to run the workflow. It will create the entire infrastructure required for the application to run. Once the infrastructure is created, please copy the ALB DNS.

After the infrastructure is created, then Run the "Deploy Application" workflow in the similar way. This will create everything, which is required for the application to work. Once this is done, please paste the ALB DNS in yor browser, it will show the "Hello World" Prompt to you.

If you have any question, please feel free to ask them.
