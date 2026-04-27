aws_region                 = "us-east-1"
project_name               = "gitops-lite"
instance_type              = "t3.micro"
key_name                   = "gitops-key"
ssh_cidr_blocks            = ["223.178.83.220/32"]
http_cidr_blocks           = ["0.0.0.0/0"]
enable_detailed_monitoring = true
cpu_alarm_threshold        = 70
