resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
  ]
  client_id_list = [
    "sts.amazonaws.com",
  ]
  tags = module.this.tags
}

data "aws_iam_policy_document" "github" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:kbrockhoff/aws-black-belt-containers:*"]
    }
  }
}

resource "aws_iam_role" "github" {
  assume_role_policy = data.aws_iam_policy_document.github.json
  name               = module.this.name_prefix
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]

  tags = merge(module.this.tags, {
    Name = module.this.name_prefix
  })
}

data "aws_iam_policy_document" "s3_backend" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::dl-aws-sbtrng-tfstate-838520979566"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::dl-aws-sbtrng-tfstate-838520979566/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = [
      "arn:aws:dynamodb:us-east-2:838520979566:table/arn:aws:s3:::dl-aws-sbtrng-tfstate-838520979566-lock"
    ]
  }
}

resource "aws_iam_policy" "s3_backend" {
  name   = "dl-aws-sbtrng-sboxtrng-k8sgreen-terraform"
  policy = data.aws_iam_policy_document.s3_backend.json

  tags = merge(module.this.tags, {
    Name = "dl-aws-sbtrng-sboxtrng-k8sgreen-terraform"
  })
}

resource "aws_iam_role_policy_attachment" "s3_backend" {
  policy_arn = aws_iam_policy.s3_backend.arn
  role       = aws_iam_role.github.name
}
