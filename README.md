# Rest API using Lambda Function
Terraform module to create AWS Lambda and API gateway with {proxy+} integration.

This module was developed to support REST API with lambda function with a primary use case of running lambda with .NET Core 3.1, so most of the default variables are set with keeping that in mind. As of now, the module has been tested with .NET Core 2.1, 2.2 and 3.1. In general, this module just creates AWS infrastructure, so ideally any runtime environment should work.

The module supports simple (default) and failover routing policy configured through variable routing_policy. Refer to the following diagram which shows all the resources which are created by the module.

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
  create_iam_role              = false
  aws_lambda_function_role_arn = "${aws_iam_role.iam_role_lambda_function.arn}"
```

Notice you need to set variable create_iam_role to false and pass arn of the role which you want to use for the lambda function. Passing flag create_iam_role may seem unnecessary, but with the Terraform before 0.12 there is an issue with count functionality. Terraform seams to evaluate functions like “count” before its terraform plan or terraform apply runs. So if I use count logic using  "${var.aws_lambda_function_role_arn == "" ? 1 : 0}" and IAM role which is being passed to the module does not exist before plan is executed, you will get error "value of 'count' cannot be computed" and hence I added a variable create_iam_role, based on which I decide if the module has to create IAM or not. The other workaround could be to force the calling module to pass the IAM role which exists, which didn't seem to be very user friendly. Adding notes here for my reference, as coming from a functional programming background, it took me some time to wrap my head around this.



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
# Examples
To get you started, there are a couple of examples in the example folder. You can run them locally. Make sure you have configured aws to run through the cli command using default. Also, make sure to update all place holders in the command below. Please note, providers in the example are all same, like dns, primary and secondary. You should update it to make sure you specify the provider correctly. Running the following command will give you an idea of what all resources will be created.

```
terraform plan -var="aws_vpc_id=<your vpc id>" -var="aws_vpc_subnet_primary=<your primary subnet>" -var="aws_vpc_subnet_secondary=<your secondary subnet>" -var="aws_zone_id=<zone id>"

terraform plan -var="aws_vpc_id=<your vpc id>" -var="aws_secondary_vpc_id=<your vpc id>" -var="aws_vpc_subnet_primary=<your primary subnet>" -var="aws_vpc_subnet_secondary=<your secondary subnet>" -var="aws_vpc_subnet_dr_primary=<your primary subnet>" -var="aws_vpc_subnet_dr_secondary=<your secondary subnet>" -var="aws_zone_id=<zone id>"

```

Once you apply the plan you should be able to go to the following url.
{var.name}-simple.${var.domain}/WeatherForecast

# Troubleshooting
- Running this for the first time may take little extra time as AWS certificate validation can take anywhere up to 40 min. 
- Deleting the security group which has been added to a lambda function, takes a long time as a security group is associated with the network interface. You can manually associate the network interface and then it will be quick. 
- Adding a new A record in Route 53 is propagated to all Route 53 servers around the world which take around a minute or two, so when you run this for the first time, it may take a minute or two. Also keep in mind, TTL for which DNS resolver caches a response. TTL is the time for which caching DNS resolvers can cache your DNS records to the length of time specified through the TTL.
- When you apply it for the first time and you get error "error getting S3 bucket tags: NoSuchBucket: The specified bucket does not exist", please run it again. I have put dependency to make sure the s3 bucket is created before lambda is created, but in case there is some issue with dependency, I am making a note here. 