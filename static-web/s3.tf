resource "aws_s3_bucket" "www" {
  bucket = "wildrydes-vinayak-rajamouli-585679"
  acl    = "public-read"
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::wildrydes-vinayak-rajamouli-585679/*"]
    }
  ]
}
POLICY

  website {
    
    index_document = "index.html"
    
    error_document = "404.html"
  }
}

resource "aws_acm_certificate" "certificate" {
  
  domain_name       = "*.${var.root_domain_name}"
  validation_method = "EMAIL"
  subject_alternative_names = ["${var.root_domain_name}"]
}

resource "aws_cloudfront_distribution" "www_distribution" {
  
  origin {
    
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = "${aws_s3_bucket.www.website_endpoint}"
    origin_id   = "${var.www_domain_name}"
  }

  enabled             = true
  default_root_object = "index.html"

   restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }
 
   viewer_certificate {
    cloudfront_default_certificate = true
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.www_domain_name}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  
}

resource "aws_route53_zone" "zone" {
  name = "${var.root_domain_name}"
}


resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "${var.www_domain_name}"
  type    = "A"

  alias = {
    name                   = "${aws_cloudfront_distribution.www_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.www_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}
