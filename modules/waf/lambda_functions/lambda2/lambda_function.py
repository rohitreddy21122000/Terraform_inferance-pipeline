import json
import boto3
import os
import PyPDF2
import docx2txt
from io import BytesIO

s3_client = boto3.client('s3')
bedrock_client = boto3.client('bedrock-runtime')

CONTRACTS_BUCKET = os.environ.get('CONTRACTS_BUCKET')


def extract_text_from_pdf(file_content):
    """Extract text from PDF file."""
    pdf_reader = PyPDF2.PdfReader(BytesIO(file_content))
    text = ""
    for page in pdf_reader.pages:
        text += page.extract_text()
    return text


def extract_text_from_docx(file_content):
    """Extract text from DOCX file."""
    return docx2txt.process(BytesIO(file_content))


def analyze_with_bedrock(text):
    """Analyze contract text using Amazon Bedrock."""
    
    prompt = f"""
    Analyze the following contract and extract key information:
    
    Contract Text:
    {text[:4000]}  # Limit to first 4000 characters
    
    Please provide:
    1. Contract type
    2. Key parties involved
    3. Important dates
    4. Key terms and conditions
    5. Obligations and responsibilities
    6. Risk factors
    
    Format the response as a structured JSON.
    """
    
    request_body = {
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 2000,
        "messages": [
            {
                "role": "user",
                "content": prompt
            }
        ]
    }
    
    response = bedrock_client.invoke_model(
        modelId="anthropic.claude-3-sonnet-20240229-v1:0",
        body=json.dumps(request_body)
    )
    
    response_body = json.loads(response['body'].read())
    return response_body['content'][0]['text']


def lambda_handler(event, context):
    """
    Extract text from documents and analyze using Bedrock.
    """
    
    try:
        # Get S3 object details from event
        s3_bucket = event.get('s3_bucket', CONTRACTS_BUCKET)
        s3_key = event.get('s3_key')
        
        if not s3_key:
            raise ValueError("s3_key is required in the event")
        
        print(f"Processing file: s3://{s3_bucket}/{s3_key}")
        
        # Download file from S3
        response = s3_client.get_object(Bucket=s3_bucket, Key=s3_key)
        file_content = response['Body'].read()
        
        # Determine file type and extract text
        file_extension = s3_key.lower().split('.')[-1]
        
        if file_extension == 'pdf':
            extracted_text = extract_text_from_pdf(file_content)
        elif file_extension in ['docx', 'doc']:
            extracted_text = extract_text_from_docx(file_content)
        else:
            raise ValueError(f"Unsupported file type: {file_extension}")
        
        print(f"Extracted {len(extracted_text)} characters of text")
        
        # Analyze with Bedrock
        analysis_result = analyze_with_bedrock(extracted_text)
        
        print(f"Bedrock analysis complete")
        
        # Save results back to S3
        result_key = s3_key.replace('contracts/', 'analysis/').replace(f'.{file_extension}', '_analysis.json')
        
        result_data = {
            'source_file': s3_key,
            'extracted_text': extracted_text[:1000],  # First 1000 chars
            'text_length': len(extracted_text),
            'analysis': analysis_result,
            'processed_at': context.aws_request_id
        }
        
        s3_client.put_object(
            Bucket=s3_bucket,
            Key=result_key,
            Body=json.dumps(result_data, indent=2),
            ContentType='application/json'
        )
        
        print(f"Saved analysis to: {result_key}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Text extraction and analysis complete',
                'result_key': result_key,
                'text_length': len(extracted_text)
            })
        }
        
    except Exception as e:
        print(f"Error extracting text: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error extracting text',
                'error': str(e)
            })
        }
