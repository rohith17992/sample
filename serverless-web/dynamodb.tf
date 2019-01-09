resource "aws_dynamodb_table" "test" {
  name           = "Rides"
  hash_key       = "RideId"
  read_capacity  = 20
  write_capacity = 20
  
  attribute {
    name = "RideId"
    type = "S"
  }
}
