locals {
  computed_major_engine_version = var.engine == "postgres" ? join(".", slice(split(".", var.engine_version), 0, 1)) : join(".", slice(split(".", var.engine_version), 0, 2))

  is_replica = try(length(var.replicate_source_db), 0) > 0

  availability_zone = var.multi_az ? null : var.availability_zone
}

resource "aws_db_parameter_group" "parameter_group" {

  name   = var.name_parameter
  family = var.db_parameter_group

  dynamic "parameter" {
    for_each = var.db_parameter
    content {
      apply_method = parameter.value.apply_method
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_option_group" "option_group" {
  engine_name          = var.engine
  major_engine_version = var.major_engine_version


  dynamic "option" {
    for_each = var.db_options
    content {
      db_security_group_memberships  = lookup(option.value, "db_security_group_memberships", null)
      option_name                    = option.value.option_name
      port                           = lookup(option.value, "port", null)
      version                        = lookup(option.value, "version", null)
      vpc_security_group_memberships = lookup(option.value, "vpc_security_group_memberships", null)

      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_db_subnet_group" "subnet_group" {
  name       = var.subnet_name
  subnet_ids = var.subnet_ids


}

resource "aws_db_instance" "db_instance" {
  db_name               = var.database_name
  username              = local.is_replica ? null : var.database_user
  password              = local.is_replica ? null : var.database_password
  port                  = var.database_port
  engine                = var.engine
  engine_version        = var.engine_version
  character_set_name    = var.charset_name
  instance_class        = var.instance_class
  allocated_storage     = local.is_replica ? null : var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_arn

  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name


  availability_zone = local.availability_zone

  ca_cert_identifier          = var.ca_cert_identifier
  parameter_group_name        = aws_db_parameter_group.parameter_group.name
  option_group_name           = aws_db_option_group.option_group.name
  license_model               = var.license_model
  multi_az                    = var.multi_az
  storage_type                = var.storage_type
  iops                        = var.iops
  publicly_accessible         = var.publicly_accessible
  snapshot_identifier         = var.snapshot_identifier
  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  maintenance_window          = var.maintenance_window
  skip_final_snapshot         = var.skip_final_snapshot
  copy_tags_to_snapshot       = var.copy_tags_to_snapshot
  backup_retention_period     = var.backup_retention_period
  backup_window               = var.backup_window

  deletion_protection = var.deletion_protection

  replicate_source_db = var.replicate_source_db
  timezone            = var.timezone

  iam_database_authentication_enabled   = var.iam_database_authentication_enabled
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn

  #   depends_on = [
  #     aws_db_parameter_group.parameter_group,
  #     aws_db_option_group.option_group
  #   ]

  lifecycle {
    ignore_changes = [
      snapshot_identifier, # if created from a snapshot, will be non-null at creation, but null afterwards
    ]
  }
}