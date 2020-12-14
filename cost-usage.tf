provider "aws" {
   region = "us-east-1"
}


resource "aws_s3_bucket" "cost_and_usage" {
  bucket = "terraform-cost-abdulu" // replace your desired bucket name for creation
  acl    = "private"
}

resource "aws_s3_bucket_policy" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "billingreports.amazonaws.com"
            },
            "Action": [
                "s3:GetBucketAcl",
                "s3:GetBucketPolicy"
            ],
            "Resource": "arn:aws:s3:::${aws_s3_bucket.cost_and_usage.id}"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "billingreports.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.cost_and_usage.id}/*"
        }
    ]
}

POLICY

}
  
resource "aws_cur_report_definition" "example_cur_report_definition" {
  report_name                = "map-migrated-rtis"
  time_unit                  = "DAILY"
  format                     = "Parquet"
  compression                = "Parquet"
  additional_schema_elements = ["RESOURCES"]
  s3_bucket                  = aws_s3_bucket.cost_and_usage.id
  s3_region                  = "us-east-1"
  s3_prefix                  = "map-migrated"
  additional_artifacts       = ["ATHENA"]
  report_versioning = "OVERWRITE_REPORT"
}
