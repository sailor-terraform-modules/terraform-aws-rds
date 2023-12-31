variable "subnet_name" {
  type        = string
  default     = "se"
  description = "subnet name"
}


variable "security_group_ids" {
  type        = list(string)
  description = "The IDs of the security groups from which to allow `ingress` traffic to the DB instance"
}

variable "region" {
  default = "us-east-2"
}


variable "database_name" {
  type        = string
  description = "The name of the database to create when the DB instance is created"
}

variable "database_user" {
  type        = string
  description = "Username for the primary DB user. Required unless a `snapshot_identifier` or `replicate_source_db` is provided."
}

variable "database_password" {
  type        = string
  description = "Password for the primary DB user. Required unless a `snapshot_identifier` or `replicate_source_db` is provided."
}

variable "database_port" {
  type        = number
  description = "Database port (_e.g._ `3306` for `MySQL`). Used in the DB Security Group to allow access to the DB instance from the provided `security_group_ids`"
}

variable "deletion_protection" {
  type        = bool
  description = "Set to true to enable deletion protection on the RDS instance"
}

variable "multi_az" {
  type        = bool
  description = "Set to true if multi AZ deployment must be supported"
}

variable "storage_type" {
  type        = string
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)"
}

variable "iops" {
  type        = number
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'. Default is 0 if rds storage type is not 'io1'"
}

variable "allocated_storage" {
  type        = number
  description = "The allocated storage in GBs. Required unless a `snapshot_identifier` or `replicate_source_db` is provided."
}

variable "max_allocated_storage" {
  type        = number
  description = "The upper limit to which RDS can automatically scale the storage in GBs"
}

variable "engine" {
  type        = string
  description = "Database engine type. Required unless a `snapshot_identifier` or `replicate_source_db` is provided."
  # http://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html
  # - mysql
  # - postgres
  # - oracle-*
  # - sqlserver-*
}

variable "engine_version" {
  type        = string
  description = "Database engine version, depends on engine type. Required unless a `snapshot_identifier` or `replicate_source_db` is provided."
  # http://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html\
}

variable "major_engine_version" {
  type        = string
  description = "Database MAJOR engine version, depends on engine type"
  # https://docs.aws.amazon.com/cli/latest/reference/rds/create-option-group.html
}

variable "charset_name" {
  type        = string
  description = "The character set name to use for DB encoding. [Oracle & Microsoft SQL only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#character_set_name). For other engines use `db_parameter`"
}

variable "license_model" {
  type        = string
  description = "License model for this DB. Optional, but required for some DB Engines. Valid values: license-included | bring-your-own-license | general-public-license"
}

variable "instance_class" {
  type        = string
  description = "Class of RDS instance"
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
}

# This is for custom parameters to be passed to the DB
# We're "cloning" default ones, but we need to specify which should be copied
variable "db_parameter_group" {
  type        = string
  description = "The DB parameter group family name. The value depends on DB engine used. See [DBParameterGroupFamily](https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBParameterGroup.html#API_CreateDBParameterGroup_RequestParameters) for instructions on how to retrieve applicable value."
  # "mysql5.6"
  # "postgres9.5"
}

variable "publicly_accessible" {
  type        = bool
  description = "Determines if database can be publicly available (NOT recommended)"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB. DB instance will be created in the VPC associated with the DB subnet group provisioned using the subnet IDs. Specify one of `subnet_ids`, `db_subnet_group_name` or `availability_zone`"
  type        = list(string)
}

variable "availability_zone" {
  type        = string
  description = "The AZ for the RDS instance. Specify one of `subnet_ids`, `db_subnet_group_name` or `availability_zone`. If `availability_zone` is provided, the instance will be placed into the default VPC or EC2 Classic"
}


variable "vpc_id" {
  type        = string
  description = "VPC ID the DB instance will be created in"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Allow automated minor version upgrade (e.g. from Postgres 9.5.3 to Postgres 9.5.4)"
}

variable "allow_major_version_upgrade" {
  type        = bool
  description = "Allow major version upgrade"
}

variable "apply_immediately" {
  type        = bool
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
}

variable "maintenance_window" {
  type        = string
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi' UTC "
}

variable "skip_final_snapshot" {
  type        = bool
  description = "If true (default), no snapshot will be made before deleting DB"
}

variable "copy_tags_to_snapshot" {
  type        = bool
  description = "Copy tags from DB to a snapshot"
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention period in days. Must be > 0 to enable backups"
}

variable "backup_window" {
  type        = string
  description = "When AWS can perform DB snapshots, can't overlap with maintenance window"
}

variable "db_parameter" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default     = [{ apply_method = "pending-reboot", name = "character_set_client", value = "utf8" }]
  description = "A list of DB parameters to apply. Note that parameters may differ from a DB family to another"
}

variable "db_options" {
  type = list(object({
    db_security_group_memberships  = list(string)
    option_name                    = string
    port                           = number
    version                        = string
    vpc_security_group_memberships = list(string)

    option_settings = list(object({
      name  = string
      value = string
    }))
  }))
  description = "A list of DB options to apply with an option group. Depends on DB engine"
}

variable "snapshot_identifier" {
  type        = string
  description = "Snapshot identifier e.g: rds:production-2019-06-26-06-05. If specified, the module create cluster from the snapshot"
}

# variable "final_snapshot_identifier" {
#   type        = string
#   description = "Final snapshot identifier e.g.: some-db-final-snapshot-2019-06-26-06-05"
#   default     = ""
# }

variable "name_parameter" {
  type        = string
  description = "name of the parameter"
}
variable "option_name" {
  type        = string
  description = "name of the option group"
}
variable "parameter_group_name" {
  type        = string
  description = "Name of the DB parameter group to associate"
}

variable "option_group_name" {
  type        = string
  description = "Name of the DB option group to associate"
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the existing KMS key to encrypt storage"
}

variable "performance_insights_enabled" {
  type        = bool
  description = "Specifies whether Performance Insights are enabled."
}

variable "performance_insights_kms_key_id" {
  type        = string
  description = "The ARN for the KMS key to encrypt Performance Insights data. Once KMS key is set, it can never be changed."
}

variable "performance_insights_retention_period" {
  description = "The amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years)."
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  default     = ["error", "audit"]
  description = "List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine): alert, audit, error, general, listener, slowquery, trace, postgresql (PostgreSQL), upgrade (PostgreSQL)."
}

variable "ca_cert_identifier" {
  type        = string
  description = "The identifier of the CA certificate for the DB instance"
  default     = "rds-ca-2019"
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. Valid Values are 0, 1, 5, 10, 15, 30, 60."
}

variable "monitoring_role_arn" {
  type        = string
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs"
}

variable "iam_database_authentication_enabled" {
  type        = bool
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
}

variable "replicate_source_db" {
  type        = string
  description = "Specifies that this resource is a Replicate database, and to use this value as the source database. This correlates to the `identifier` of another Amazon RDS Database to replicate (if replicating within a single region) or ARN of the Amazon RDS Database to replicate (if replicating cross-region). Note that if you are creating a cross-region replica of an encrypted database you will also need to specify a `kms_key_id`. See [DB Instance Replication](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.Replication.html) and [Working with PostgreSQL and MySQL Read Replicas](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html) for more information on using Replication."
}

variable "timezone" {
  type        = string
  description = "Time zone of the DB instance. timezone is currently only supported by Microsoft SQL Server. The timezone can only be set on creation. See [MSSQL User Guide](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_SQLServer.html#SQLServer.Concepts.General.TimeZone) for more information."
}
variable "secret_name" {
  type        = string
  description = "Secret Name"
}