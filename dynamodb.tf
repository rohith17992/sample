resource "aws_dynamodb_table" "test" {
  name           = "Rides"
  hash_key       = "RideId"
}