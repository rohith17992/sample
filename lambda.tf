
data "aws_iam_policy" "ReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "DynamoDBAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}


resource "aws_iam_role" "WildRole" {
  name = "WildRole"
}


resource "aws_iam_role_policy_attachment" "policy-attach-1" {
  role = "${aws_iam_role.WildRole.name}"
  policy_arn = "${data.aws_iam_policy.DynamoDBAccess.arn}"
}

resource "aws_iam_role_policy_attachment" "policy-attach-2" {
  role = "${aws_iam_role.WildRole.name}"
  policy_arn = "${data.aws_iam_policy.ReadOnlyAccess.arn}"
}


resource "aws_lambda_function" "test_lambda" {

  function_name = "WildLambda"

  

  s3_bucket = "${var.artifact_s3_bucket}"
  s3_key    = "${var.artifact_s3_object_key}"

  runtime     = "$node6.10"
  handler     = "index.js"
  memory_size = "${var.lambda_memory_size}"
  timeout     = "${var.lambda_timeout}"
  role        = "${var.lambda_execution_role}"
  environment {
    variables = "${var.environment_variables}"
  }
}


resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.main.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.proxy.id}/*/*/*"
}
