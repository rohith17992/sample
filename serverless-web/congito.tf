resource "aws_cognito_user_pool" "pool" {
  name = "WildRydes"
}

resource "aws_cognito_user_pool_client" "client" {
  name = "WildRydesWebApp"
  generate_secret = true

  user_pool_id = "${aws_cognito_user_pool.pool.id}"
}
