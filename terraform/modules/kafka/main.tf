module "sg" {
  source = "../security-group"

  name                      = "${var.name}-sg"
  description               = "Ingress to ${var.name} brokers from EKS pods only."
  vpc_id                    = var.vpc_id
  ingress_port              = 9092
  ingress_port_to           = 9098
  source_security_group_ids = var.source_security_group_ids
  allowed_cidrs             = var.allowed_cidrs
  tags                      = var.tags
}

# Independent MSK cluster per region. The DR cluster is empty at steady
# state (no MirrorMaker / Replicator): redemption events are an operation
# log whose source-of-truth is RDS, so consumers replay from the last
# persisted offset after failover. App reconfig is a ConfigMap swap (RD-01).
resource "aws_msk_cluster" "this" {
  cluster_name           = var.name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.broker_nodes

  broker_node_group_info {
    instance_type   = var.broker_instance_type
    client_subnets  = var.subnet_ids
    security_groups = [module.sg.security_group_id]
    storage_info {
      ebs_storage_info {
        volume_size = var.ebs_volume_size
      }
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = var.kms_key_arn
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  client_authentication {
    sasl { iam = true }
  }

  open_monitoring {
    prometheus {
      jmx_exporter { enabled_in_broker = true }
      node_exporter { enabled_in_broker = true }
    }
  }

  tags = merge(var.tags, { Role = var.role })
}
