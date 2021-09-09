resource "aws_s3_bucket" "obs-tempo" {
  bucket = "${random_id.random.hex}-grafana-tempo"
  acl    = "private"
  force_destroy = true 

  tags = {
    Name        = "Grafana Tempo Bucket"
  }
}

resource "aws_s3_bucket" "obs-loki" {
  bucket = "${random_id.random.hex}-loki"
  acl    = "private"
  force_destroy = true 

  tags = {
    Name        = "Grafana Loki Bucket"
  }
}