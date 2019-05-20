## Network Interfaces

resource "aws_network_interface" "core" {
  count             = length(local.core_subnet_ids)
  subnet_id         = element(local.core_subnet_ids, count.index)
  security_groups   = list(element(aws_security_group.this.*.id, 0))
  private_ips       = list(element(["10.244.128.10", "10.244.0.10"], count.index))
  source_dest_check = true
  tags = element([
    {
      Name = "ec2-1b-eni"
    },
    {
      Name = "ec2-1a-eni"
    }
  ], 0)
}

resource "aws_network_interface" "stubs" {
  count             = length(local.stub_subnet_ids)
  subnet_id         = element(local.stub_subnet_ids, count.index)
  security_groups   = list(element(aws_security_group.this.*.id, count.index + 1))
  private_ips       = list(element(["10.245.128.10", "10.246.128.10"], count.index))
  source_dest_check = true
  tags = element([
    {
      Name = "ec2-2-eni"
    },
    {
      Name = "ec2-3-eni"
    }
  ], 0)
}

## Core VPC Instances

resource "aws_instance" "ec2_1a" {
  ami           = data.aws_ami.amzn2_linux.id
  instance_type = "t2.micro"
  key_name      = "aws-dev-key"

  network_interface {
    network_interface_id = aws_network_interface.core[1].id
    device_index         = 0
  }

  user_data = <<EOF
  #!/bin/bash -xe

  set -o xtrace
  sudo hostname ec2-1a-ssh-bastion
  sudo echo "ec2-1a-ssh-bastion" > /etc/hostname
EOF

}

resource "aws_instance" "ec2_1b" {
  ami = data.aws_ami.amzn2_linux.id
  instance_type = "t2.micro"
  key_name = "aws-dev-key"

  network_interface {
    network_interface_id = aws_network_interface.core[0].id
    device_index = 0
  }

  user_data = <<EOF
  #!/bin/bash -xe

  set -o xtrace
  sudo hostname ec2-1b
  sudo echo "ec2-1b" > /etc/hostname
EOF

}

output "ec2_1a_public_ip" {
value = aws_instance.ec2_1a.public_ip
}

output "ec2_1a_private_ip" {
value = aws_instance.ec2_1a.private_ip
}

output "ec2_1b_private_ip" {
value = aws_instance.ec2_1b.private_ip
}

## Stub VPC Instances

resource "aws_instance" "ec2_2" {
  ami           = data.aws_ami.amzn2_linux.id
  instance_type = "t2.micro"
  key_name      = "aws-dev-key"

  network_interface {
    network_interface_id = aws_network_interface.stubs[0].id
    device_index         = 0
  }

  user_data = <<EOF
  #!/bin/bash -xe

  set -o xtrace
  sudo hostname ec2-2
  sudo echo "ec2-2" > /etc/hostname
EOF

}

output "ec2_2_private_ip" {
  value = aws_instance.ec2_2.private_ip
}

resource "aws_instance" "ec2_3" {
  ami = data.aws_ami.amzn2_linux.id
  instance_type = "t2.micro"
  key_name = "aws-dev-key"

  network_interface {
    network_interface_id = aws_network_interface.stubs[1].id
    device_index = 0
  }

  user_data = <<EOF
  #!/bin/bash -xe

  set -o xtrace
  sudo hostname ec2-3
  sudo echo "ec2-3" > /etc/hostname
EOF

}

output "ec2_3_private_ip" {
  value = aws_instance.ec2_3.private_ip
}
