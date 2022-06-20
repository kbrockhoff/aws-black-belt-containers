resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  thumbprint_list = [
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
