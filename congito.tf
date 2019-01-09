resource "aws_cognito_user_pool" "pool" {
  name = "WildRydes"
}

resource "aws_cognito_user_pool_client" "client" {
  name = "WildRydesWebApp"

  user_pool_id = "${aws_cognito_user_pool.pool.id}"
}
