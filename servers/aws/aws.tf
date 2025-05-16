variable "token" {
    default = "abc"

}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "teleport_aws_access" {
  name = "TeleportAWSAccess"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "teleport_aws_access_assume_policy" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.teleport_aws_access.arn]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "AssumeExampleReadOnlyRole"
  description = "Allows read-only access to AWS resources through the AWS-managed ReadOnlyAccess policy"
  policy      = data.aws_iam_policy_document.teleport_aws_access_assume_policy.json
}

resource "aws_iam_policy_attachment" "teleport_aws_access_policy_attach" {
  name       = "TeleportAWSAccess"
  roles      = [aws_iam_role.teleport_aws_access.name]
  policy_arn = aws_iam_policy.policy.arn
}

# ------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "example_read_only_access_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TeleportAWSAccess"]
    }
  }
}

resource "aws_iam_role" "example_read_only_access" {
  name = "ExampleReadOnlyAccess"

  assume_role_policy = data.aws_iam_policy_document.example_read_only_access_policy.json
}

data "aws_iam_policy" "read_only_access_policy" {
  name = "ReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "example_read_only_access_policy_attach" {
  name       = "ExampleReadOnlyAccess "
  roles      = [aws_iam_role.example_read_only_access.name]
  policy_arn = data.aws_iam_policy.read_only_access_policy.arn
}

# --------------------------------------------------------------------------------------------

resource "aws_iam_instance_profile" "teleport_aws_access" {
  name = "TeleportAWSAccess"
  role = aws_iam_role.teleport_aws_access.name
}

# -----------------------------------------------------------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "teleport" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  user_data_base64 = base64encode(
    <<EOT
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install curl -y
    curl "https://teleport.razorcorp.dev/scripts/install.sh" | bash
    cat <<-EOF | tee
    version: v3
    teleport:
    join_params:
        token_name: ${var.token}
        method: token
    proxy_server: "teleport.razorcorp.dev:443"
    auth_service:
    enabled: false
    proxy_service:
    enabled: false
    ssh_service:
    enabled: false
    app_service:
    enabled: true
    apps:
    - name: "awsconsole"
    # The public AWS Console is used after authenticating the user from Teleport
        uri: "https://console.aws.amazon.com/ec2/v2/home"
    EOF
    sudo systemctl enable teleport
    sudo systemctl start teleport
    EOT
  )
}