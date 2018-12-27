



resource "aws_api_gateway_rest_api" "wildapi" {
  name        = "WildAPI"
  description = "API"
}

resource "aws_api_gateway_authorizer" "demo" {
  name                   = "WildRydes"
  rest_api_id            = "${aws_api_gateway_rest_api.wildapi.id}"
  type                   = "COGNITO_USER_POOLS"
  provider_arns          = ["arn:aws:cognito-idp:eu-west-1:687090927093:userpool/eu-west-1_KidugZQbb"]
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

resource "aws_api_gateway_integration" "lambdo" {
  rest_api_id = "${aws_api_gateway_rest_api.wildapi.id}"
  resource_id = "${aws_api_gateway_resource.ride.id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:687090927093:function:RequestUnicorn/invocations"
}


resource "aws_api_gateway_deployment" "main" {
  depends_on = [
    "aws_api_gateway_integration.lambdo"
  ]

  rest_api_id = "${aws_api_gateway_rest_api.wildapi.id}"
  stage_name  = "test"
}



