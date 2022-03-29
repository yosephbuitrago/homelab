resource "aws_route53_zone" "primary" {
  name = var.zone_name
  tags = var.tags
}

resource "aws_iam_user" "external_dns" {
  name = "external-dns"
  tags = var.tags
}

resource "aws_iam_access_key" "external_dns" {
  user = aws_iam_user.external_dns.name
}

resource "aws_secretsmanager_secret" "external_dns_secret_access_key" {
  name = "external-dns-secret-access-key"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "external_dns_secret_access_key" {
  secret_id     = aws_secretsmanager_secret.external_dns_secret_access_key.id
  secret_string = aws_iam_access_key.external_dns.secret
}

resource "aws_iam_user_policy" "external_dns" {
  name   = "external-dns"
  user   = aws_iam_user.external_dns.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "${aws_route53_zone.primary.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_user" "cert_manager" {
  name = "cert-manager"
  tags = var.tags
}

resource "aws_iam_access_key" "cert_manager" {
  user = aws_iam_user.cert_manager.name
}

resource "aws_secretsmanager_secret" "cert_manager_secret_access_key" {
  name = "cert-manager-secret-access-key"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "cert_manager_secret_access_key" {
  secret_id     = aws_secretsmanager_secret.cert_manager_secret_access_key.id
  secret_string = aws_iam_access_key.cert_manager.secret
}

resource "aws_iam_user_policy" "cert_manager" {
  name   = "cert-manager"
  user   = aws_iam_user.cert_manager.name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "route53:GetChange",
            "Resource": "arn:aws:route53:::change/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets",
                "route53:ListResourceRecordSets"
            ],
            "Resource": "${aws_route53_zone.primary.arn}"
        },
        {
            "Effect": "Allow",
            "Action": "route53:ListHostedZonesByName",
            "Resource": "*"
        }
    ]
}
EOF
}