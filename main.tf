resource "aws_docdb_cluster" "main" {
  cluster_identifier      = "${var.env}-docdb"
  engine                  = var.engine
  engine_version = var.engine_version
  master_username         = data.aws_ssm_parameter.user.value
  master_password         = data.aws_ssm_parameter.pass.value
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot     = var.skip_final_snapshot
  #db_subnet_group_name = aws_docdb_subnet_group.main.name
  kms_key_id = data.aws_kms_key.key.arn
  storage_encrypted = var.storage_encrypted
  #vpc_security_group_ids = [aws_security_group.main.id]
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = var.no_of_instances
  identifier         = "${var.env}-docd-${count.index}"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = var.instance_class
}

resource "aws_security_group" "main" {
  name        = "docdb-${var.env}"
  description = "docdb-${var.env}"
  vpc_id      = var.vpc_id

  ingress {
    description = "DOCDB"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = var.allow_subnets
  }

  tags = merge(
    var.tags,
    { Name = "docdb-${var.env}" }
  )
}


#resource "aws_vpc_security_group_ingress_rule" "ingress2" {
#  security_group_id = aws_security_group.main.id
#  cidr_ipv4         = var.allow_app_to
#  from_port         = var.port
#  ip_protocol       = "tcp"
#  to_port           = var.port
#  description = "APP"
#}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_docdb_subnet_group" "main" {
  name       = "${var.env}-docdb"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    { Name = "${var.env}-subnet-group" }
  )
}


resource "aws_ssm_parameter" "docdb_url" {
  name = "${var.env}.docdb.url.catalogue"
  type = "String"
  #value = "mongodb://${data.aws_ssm_parameter.user.value}:${data.aws_ssm_parameter.pass.value}@dev-docdb.cluster-clarhbmazh1y.us-east-1.docdb.amazonaws.com:27017/?tls=true&tlsCAFile=global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
  value = "mongodb://${data.aws_ssm_parameter.user.value}:${data.aws_ssm_parameter.pass.value}@dev-docdb.cluster-clarhbmazh1y.us-east-1.docdb.amazonaws.com:27017/catalogue?tls=true&tlsCAFile=global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
}

resource "aws_ssm_parameter" "docdb_url_user" {
  name = "${var.env}.docdb.url.user"
  type = "String"
  value = "mongodb://${data.aws_ssm_parameter.user.value}:${data.aws_ssm_parameter.pass.value}@dev-docdb.cluster-clarhbmazh1y.us-east-1.docdb.amazonaws.com:27017/users?tls=true&tlsCAFile=global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
}

resource "aws_ssm_parameter" "docdb_endpoint" {
  name = "${var.env}.docdb.endpoint"
  type = "String"
  value = aws_docdb_cluster.main.endpoint
}




