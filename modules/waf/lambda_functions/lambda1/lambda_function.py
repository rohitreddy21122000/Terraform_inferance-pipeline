import json
import boto3
import os
from datetime import datetime

s3_client = boto3.client('s3')
secrets_client = boto3.client('secretsmanager')
sfn_client = boto3.client('stepfunctions')

CONTRACTS_BUCKET = os.environ.get('CONTRACTS_BUCKET')
SECRET_ARN = os.environ.get('SECRET_ARN')
STEP_FUNCTION_ARN = os.environ.get('STEP_FUNCTION_ARN')


def lambda_handler(event, context):
    """
    Webhook handler for processing incoming requests.
    This function receives webhook events, validates them, uploads to S3,
    and triggers Step Functions workflow.
    """
    
    try:
        # Parse the incoming webhook payload
        body = json.loads(event.get('body', '{}'))
        
        print(f"Received webhook event: {json.dumps(body)}")
        
        # Retrieve webhook credentials from Secrets Manager
        secret_response = secrets_client.get_secret_value(SecretId=SECRET_ARN)
        credentials = json.loads(secret_response['SecretString'])
        
        # Validate webhook (implement your validation logic here)
        # Example: Check signature, validate source, etc.
        
        # Extract relevant data from webhook
        file_data = body.get('attachment', {})
        file_content = file_data.get('content', '')
        file_name = file_data.get('filename', f'contract_{datetime.now().strftime("%Y%m%d%H%M%S")}.pdf')
        
        # Upload to S3
        s3_key = f"contracts/{file_name}"
        s3_client.put_object(
            Bucket=CONTRACTS_BUCKET,
            Key=s3_key,
            Body=file_content,
            ContentType='application/pdf'
        )
        
        print(f"Uploaded file to S3: {s3_key}")
        
        # Trigger Step Functions workflow
        execution_input = {
            's3_bucket': CONTRACTS_BUCKET,
            's3_key': s3_key,
            'webhook_data': body
        }
        
        response = sfn_client.start_execution(
            stateMachineArn=STEP_FUNCTION_ARN,
            input=json.dumps(execution_input)
        )
        
        print(f"Started Step Function execution: {response['executionArn']}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Webhook processed successfully',
                'execution_arn': response['executionArn']
            })
        }
        
    except Exception as e:
        print(f"Error processing webhook: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error processing webhook',
                'error': str(e)
            })
        }
