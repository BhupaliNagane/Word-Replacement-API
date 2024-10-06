resource "aws_lambda_function" "replace_function" {
  filename         = "lambda.zip"
  function_name    = "word-replace-api"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda.zip")


  environment {
    variables = {
      REPLACEMENTS = jsonencode({
        Google  = "Google©",
        Fugro   = "Fugro B.V.",
        Holland = "The Netherlands"
      })
    }
  }
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.replace_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.word-replace-api.execution_arn}/*/*"
}