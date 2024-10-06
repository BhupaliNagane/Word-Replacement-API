resource "aws_api_gateway_rest_api" "word-replace-api" {
  name        = "word-replace-api"
  description = "API to replace words in a string"
}

resource "aws_api_gateway_resource" "replace" {
  rest_api_id = aws_api_gateway_rest_api.word-replace-api.id
  parent_id   = aws_api_gateway_rest_api.word-replace-api.root_resource_id
  path_part   = "replace"
}

resource "aws_api_gateway_method" "post_replace" {
  rest_api_id   = aws_api_gateway_rest_api.word-replace-api.id
  resource_id   = aws_api_gateway_resource.replace.id
  http_method   = "POST"
  authorization = "NONE"
  request_parameters = {
    "method.request.header.Content-Type" = true
  }

  request_models = {
    "application/json" = aws_api_gateway_model.json_model.name
  }
}

resource "aws_api_gateway_model" "json_model" {
  rest_api_id  = aws_api_gateway_rest_api.word-replace-api.id
  name         = "JsonModel"
  content_type = "application/json"
  schema = jsonencode({
    type = "object",
    properties = {
      input_text = {
        type = "string"
      }
    },
    required = ["input_text"]
  })
}

resource "aws_api_gateway_integration" "post_replace_integration" {
  rest_api_id             = aws_api_gateway_rest_api.word-replace-api.id
  resource_id             = aws_api_gateway_resource.replace.id
  http_method             = aws_api_gateway_method.post_replace.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.replace_function.invoke_arn
}

resource "aws_api_gateway_deployment" "test" {
  rest_api_id = aws_api_gateway_rest_api.word-replace-api.id
  stage_name  = "test"

  depends_on = [
    aws_api_gateway_integration.post_replace_integration,
    aws_lambda_permission.allow_apigateway,
  ]
}
