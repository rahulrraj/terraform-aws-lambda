resource "aws_api_gateway_rest_api" "api_gateway" {
  count       = "${var.enable ? 1 : 0}"
  name        = "${var.name}"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "proxy" {
  count       = "${var.enable ? 1 : 0}"
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway.root_resource_id}"
  path_part   = "{proxy+}"
}


resource "aws_api_gateway_method" "request_method" {
  count         = "${var.enable ? 1 : 0}"
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters {
      method.request.path.proxy = "true"
  }
 }

resource "aws_api_gateway_integration" "request_method_integration" {
  count                   = "${var.enable ? 1 : 0}"
  rest_api_id 	          = "${aws_api_gateway_rest_api.api_gateway.id}"
	resource_id             = "${aws_api_gateway_resource.proxy.id}"
  http_method 	          = "${aws_api_gateway_method.request_method.http_method}"
  type 			              = "AWS_PROXY"
	integration_http_method = "POST"
  uri                     = "${aws_lambda_function.lambda_function.invoke_arn}"
}


resource "aws_api_gateway_method_response" "response_method" {
  count         = "${var.enable ? 1 : 0}"
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway.id}"
	resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "${aws_api_gateway_integration.request_method_integration.http_method}"
  status_code   = "200"
	response_models = {
		"application/json" = "Empty"
	}
}

resource "aws_api_gateway_integration_response" "response_method_integration" {
  count       = "${var.enable ? 1 : 0}"
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
	resource_id = "${aws_api_gateway_resource.proxy.id}"
	http_method = "${aws_api_gateway_method_response.response_method.http_method}"
	status_code = "${aws_api_gateway_method_response.response_method.status_code}"
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  count       = "${var.enable ? 1 : 0}"
  depends_on  = [
    "aws_api_gateway_integration.request_method_integration"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
  stage_name  = "${var.stage_name}"
 }

# https://aws.amazon.com/premiumsupport/knowledge-center/500-error-lambda-api-gateway/
resource "aws_lambda_permission" "allow_api_gateway" {
  count         = "${var.enable ? 1 : 0}"
  function_name = "${aws_lambda_function.lambda_function.function_name}"
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*/*"
}
