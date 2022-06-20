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
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:kbrockhoff/aws-black-belt-containers:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "github" {
  assume_role_policy = data.aws_iam_policy_document.github.json
  name               = module.this.name_prefix

  tags = merge(module.this.tags, {
    Name = module.this.name_prefix
  })
}

resource "aws_iam_role_policy_attachment" "github" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.github.name
}
