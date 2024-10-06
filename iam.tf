resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "cloudwatch_logs_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "LambdaCloudWatchLogsPolicy"
  description = "Policy to allow Lambda functions to write logs to CloudWatch"

  policy = data.aws_iam_policy_document.cloudwatch_logs_policy_document.json
}

resource "aws_iam_role_policy_attachment" "attach_logs_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}
