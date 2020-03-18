# Rest API using Lambda Function
Terraform module to create AWS Lambda and API gateway with {proxy+} integration.

This module was developed to support REST API with lambda function with a primary use case of running lambda with .NET Core 3.1, so most of the default variables are set with keeping that in mind. As of now, the module has been tested with .NET Core 2.1, 2.2 and 3.1. In general, this module just creates AWS infrastructure, so ideally any runtime environment should work.

The module supports simple (default) and failover routing policy configured through variable routing_policy. Refer following diagram which shows all the resources which are created by the module.

![multi-region-lambda](documentation/multi-region-lambda.jpg)

# Extend Lambda IAM role
The module creates an IAM role for the lambda function and adds access to S3, ENI, lambda, Xray, log. These are common AWS services that are required for lambda to run. For adding any additional role policy, the module returns the AWS IAM role arn and its name. You can use them in the calling module to add any additional policy like access to a specific dynamo table. Refer following example

```
	resource "aws_iam_role_policy" "iam_role_policy_lambda_function" {
	  name    = "${var.name}-dynamodb-lambda-function"
	  role    = "${module.my_simple_api.lambda_iam_role_name[0]}"
	  policy  = "${file("${path.module}/template/lambda-function-iam-policy-dynamo-db.json")}"
	}

```

In case you do not want the module to create an IAM role, the calling module can pass IAM role aws_lambda_function_role_arn, which will be used in the lambda function. Refer following example

```
	aws_lambda_function_role_arn = "${aws_iam_role.iam_role_lambda_function.arn}"
```

# Extend Lambda Security Group
The module creates a security group for the lambda function and add ingress rule for HTTP(80) and HTTPs(443) and add egress to access Splunk (8088). For any additional application-level ingress/egress rule, the module outputs security_group_id for the primary website and also for the secondary in case of failover. This will enable you to add additional security group rules, like opening port to access the SQL server. The SG id for the secondary lambda resource is returned as an array so you need to access it as [0]. Refer following example, which will add egress rule to the security group

```
resource "aws_security_group_rule" "sql_egress" {
  type              = "egress"
  from_port         = 1433
  to_port           = 1433
  protocol          = "tcp"
  security_group_id = "${module.my_simple_api.lambda_security_group_id}"
  description       = "connect to sql db"
  cidr_blocks       = ["10.0.0.0/8"]
  
}
```

# Known Issue
- Running this for the first time may take little extra time as AWS certificate validation can take anywhere up to 40 min
- Running this for the first time with failover fails with an error about missing s3 bucket (S3 Error Code: NoSuchKey. S3 Error Message: The specified key does not exist.). Re-run it and it should be fine. Looking into it to find how to handle it. 
- Deleting the security group which has been added to a lambda function, takes a long time as a security group is associated with the network interface. You can manually associate the network interface and then it will be quick. 
