import os
import json
import boto3

s3 = boto3.client("s3")
step = boto3.client("stepfunctions")

def lambda_handler(event, context):
    print("Event:", json.dumps(event))
    body = event.get("body")
    if body:
        try:
            payload = json.loads(body)
        except:
            payload = {"body": body}
    else:
        payload = event

    # Example: store incoming payload in S3 uploads
    bucket = os.environ.get("S3_BUCKET_NAME")
    key = f"uploads/{payload.get('filename','anon')}"
    s3.put_object(Bucket=bucket, Key=key, Body=json.dumps(payload))

    # Start Step Function
    sm_arn = os.environ.get("STATE_MACHINE_ARN")
    step.start_execution(stateMachineArn=sm_arn, input=json.dumps(payload))

    return {
        "statusCode": 200,
        "body": json.dumps({"message":"accepted","key":key})
    }
