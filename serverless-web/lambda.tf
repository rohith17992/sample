
data "aws_iam_policy" "ReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "DynamoDBAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}


resource "aws_iam_role" "WildRole" {
  name = "WildRoleHyd"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
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

  function_name = "RequestUnicorn"
  filename = "lambda_function.zip"

  runtime     = "nodejs6.10"
  handler     = "index.js"
  role        = "${aws_iam_role.WildRole.arn}"
 
}

/*
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.main.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_re}
*/
