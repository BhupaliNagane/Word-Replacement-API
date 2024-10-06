import json

REPLACEMENTS = {
    "Google": "Google©",
    "Fugro": "Fugro B.V.",
    "Holland": "The Netherlands"
}

def lambda_handler(event, context):
    try:
       
        print("Received event:", json.dumps(event))

        if "body" not in event or not event["body"]:
            raise ValueError("Missing body in the request")

        body = json.loads(event["body"])
        input_text = body.get("input_text", "")

        if not input_text:
            raise ValueError("Missing input_text in the body")

        output_text = input_text
        for word, replacement in REPLACEMENTS.items():
            output_text = output_text.replace(word, replacement)

        return {
            'statusCode': 200,
            'body': json.dumps({
                "original": input_text,
                "modified": output_text
            }),
            'headers': {
                'Content-Type': 'application/json'
            }
        }
    except ValueError as ve:
        return {
            'statusCode': 400,
            'body': json.dumps({"error": str(ve)}),
            'headers': {
                'Content-Type': 'application/json'
            }
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({"error": "Internal server error: " + str(e)}),
            'headers': {
                'Content-Type': 'application/json'
            }
        }
