# Rest API using Lambda Function
Terraform module to create AWS Lambda and API gateway with {proxy+} integration.

This module was developed to support REST api with lambda function with a primary use case of running lambda with .NET Core 3.1, so most of the default variable are set with keeping that in mind. As of now the module had been tested with 2.1, 2.2 and 3.1.

!(documentation\multi-region-lambda.png)

# Extend Lambda IAM role
The module creates an IAM role for the lambda function and adds access to s3, ENI, lambda, xRay, log. For adding any additional role policy, the module returns the AWS IAM role arn and its name. You can use them in the calling module to add any additional policy like access to a specific dynamo table.

# Extend Lambda Security Group
The module creates a security group for the lambda function and add ingress rule for HTTP(80) and HTTPs(443) and add egress to access Splunk (8088). For any additional application-level ingress/egress rule, the module outputs security_group_id for the primary website and also for the secondary in case of failover. This will enable you to add additional security group rules, like opening port to access the SQL server. The SG id for the secondary lambda resource is returned as an array so you need to access it as [0].