
provider "aws"{
  region = "us-east-1"
}


resource "aws_api_gateway_rest_api" "wildapi" {
  name        = "${var.api_gateway_name}"
  description = "${var.description}"
}

resource "aws_api_gateway_authorizer" "demo" {
  name                   = "WildRydes"
  rest_api_id            = "${aws_api_gateway_rest_api.wildapi.id}"
  type                   = "COGNITO_USER_POOLS"
  provider_arn           = ["${aws_cognito_user_pool.WildRydes.arn}"]
  identity_validation_expression ="AUTHORIZER"
}

resource "aws_api_gateway_resource" "ride" {
  rest_api_id = "${aws_api_gateway_rest_api.wildapi.id}"
  parent_id   = "${aws_api_gateway_rest_api.wildapi.root_resource_id}"
  path_part   = "{ride}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.wildapi.id}"
  resource_id   = "${aws_api_gateway_resource.ride.id}"
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = "${aws_api_gateway_authorizer.demo.id}"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.wildapi.id}"
  resource_id = "${aws_api_gateway_method.ride.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.main.invoke_arn}"
}


resource "aws_api_gateway_deployment" "main" {
  depends_on = [
    "aws_api_gateway_integration.lambda"
  ]

  rest_api_id = "${aws_api_gateway_rest_api.wildapi.id}"
  stage_name  = "test"
}



