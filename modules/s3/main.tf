region: ${ region }

s3:
  bucket_name: ${ s3_bucket_name }
  access_logs_bucket: ${ s3_bucket_name }-access-logs
  folders:
    - uploads/
    - extracted/
  versioning_enabled: true
  encryption:
    algorithm: AES256
    bucket_key_enabled: true
  lifecycle:
    expiration_days:
      prod: 2555
      qa: 365
      dev: 90
    noncurrent_version_expiration_days: 30
  logging:
    target_prefix: access-logs/

lambda:
  runtime: python3.13
  architecture: x86_64
  layer:
    name: Tech-TextExtractlayer
    compatible_runtimes:
      - python3.13
      - python3.12
      - python3.11
    description: Document processing dependencies - PyPDF2, docx2txt, requests
  webhook:
    function_name: tech-webhooklambda
    role_name: tech-webhooklambdarole
    handler: lambda_function.lambda_handler
    memory_size: 512
    timeout: 90
    max_event_age_seconds: 21600
    max_retry_attempts: 2
    environment_variables:
      JIRA_API_TOKEN: ${ jira_api_token }
      JIRA_BASE_URL: ${ jira_base_url }
      JIRA_EMAIL: ${ jira_email }
      JIRA_WEBHOOK_SECRET: ${ jira_webhook_secret }
      S3_BUCKET_NAME: ${ s3_bucket_name }
  document_processor:
    function_name: tech-ExtractText
    role_name: tech-extracttextlambda
    handler: lambda_function.lambda_handler
    memory_size: 512
    timeout: 180
    max_event_age_seconds: 21600
    max_retry_attempts: 2
    environment_variables:
      S3_BUCKET_NAME: ${ s3_bucket_name }

iam:
  webhook_lambda:
    role_name: tech-webhooklambdarole
    policies:
      - name: tech-webhooklambdapolicy
        permissions:
          - s3:PutObject
          - s3:PutObjectAcl
          - states:StartExecution
          - logs:CreateLogGroup
          - logs:CreateLogStream
          - logs:PutLogEvents
  extracttext_lambda:
    role_name: tech-extracttextlambda
    policies:
      - name: tech-extracttext-policy
        permissions:
          - s3:GetObject
          - s3:PutObject
          - bedrock:InvokeModel
          - bedrock:InvokeModelWithResponseStream
          - logs:CreateLogStream
          - logs:PutLogEvents
  step_functions:
    role_name: TechAnalysisWorkflow-role
    policies:
      - name: TechAnalysisWorkflow-policy
        permissions:
          - lambda:InvokeFunction
          - s3:GetObject
          - states:InvokeHTTPEndpoint
          - events:RetrieveConnectionCredentials
          - secretsmanager:GetSecretValue
          - secretsmanager:DescribeSecret
          - logs:CreateLogDelivery
          - logs:GetLogDelivery
          - logs:ListLogDeliveries
          - logs:CreateLogStream
          - logs:CreateLogGroup
          - logs:PutLogEvents

api_gateway:
  name: webhookAPI
  description: API Gateway for webhook processing
  endpoint_type: REGIONAL
  binary_media_types:
    - "*/*"
  stage:
    name: stage1
    cache_cluster_enabled: false
    xray_tracing_enabled: true
  resource:
    path_part: webhook
  method:
    http_method: POST
    authorization: NONE
    api_key_required: false
  integration:
    type: AWS_PROXY
    http_method: POST
    timeout_ms: 29000
  method_settings:
    throttling_rate_limit: 1000
    throttling_burst_limit: 500
    caching_enabled: false
    metrics_enabled: true
    logging_level: INFO
    data_trace_enabled: true

step_functions:
  state_machine_name: TechContractAnalysisWorkflow
  role_name: TechAnalysisWorkflow-role
  type: STANDARD
  logging:
    level: ALL
    include_execution_data: true

eventbridge:
  connection:
    name: Jira-Connection-${ environment }
    description: EventBridge connection to Jira API for ${ environment } environment
    authorization_type: BASIC
    headers:
      - key: Content-Type
        value: application/json
      - key: Accept
        value: application/json
      - key: User-Agent
        value: PFJ-Legal-Tech-Contracts/1.0

waf:
  acl:
    name: webhook-ACL
    scope: REGIONAL
    default_action: block
  ip_sets:
    jira_ipv4:
      name: jira-ipv4-ranges
      scope: REGIONAL
      version: IPV4
      addresses:
        - 18.184.99.224/28
        - 18.234.32.224/28
        - 13.52.5.96/28
        - 52.215.192.224/28
        - 104.192.136.0/21
        - 13.200.41.128/25
        - 16.63.53.128/25
        - 13.236.8.224/28
        - 43.202.69.0/25
        - 185.166.140.0/22
        - 18.246.31.224/28
        - 18.136.214.96/28
    jira_ipv6:
      name: jira-ipv6-ranges
      scope: REGIONAL
      version: IPV6
      addresses:
        - 2a05:d014:0f99:dd04:0000:0000:0000:0000/63
        - 2a05:d018:034d:5804:0000:0000:0000:0000/63
        - 2600:1f14:0824:0306:0000:0000:0000:0000/64
        - 2406:da1c:01e0:a206:0000:0000:0000:0000/64
        - 2600:1f1c:0cc5:2304:0000:0000:0000:0000/63
        - 2600:1f18:2146:e306:0000:0000:0000:0000/64
        - 2406:da1c:01e0:a204:0000:0000:0000:0000/63
        - 2600:1f18:2146:e304:0000:0000:0000:0000/63
        - 2a05:d018:034d:5806:0000:0000:0000:0000/64
        - 2406:da18:0809:0e06:0000:0000:0000:0000/64
        - 2a05:d014:0f99:dd06:0000:0000:0000:0000/64
        - 2600:1f14:0824:0304:0000:0000:0000:0000/63
        - 2406:da18:0809:0e04:0000:0000:0000:0000/63
        - 2401:1d80:3000:0000:0000:0000:0000:0000/36
  rules:
    - name: AllowJiraIPv4
      priority: 1
      action: allow
    - name: AllowJiraIPv6
      priority: 2
      action: allow
    - name: AWS-AWSManagedRulesAnonymousIpList
      priority: 50
      action: none
    - name: AWS-AWSManagedRulesKnownBadInputsRuleSet
      priority: 200
      action: none
    - name: AWS-AWSManagedRulesSQLiRuleSet
      priority: 201
      action: none
    - name: AWS-AWSManagedRulesCommonRuleSet
      priority: 700
      action: none

cloudwatch:
  log_retention_days: 14
  xray_tracing_enabled: true
  log_groups:
    webhook_lambda: /aws/lambda/tech-webhooklambda
    extracttext_lambda: /aws/lambda/tech-ExtractText
    api_gateway: /aws/apigateway/webhookAPI
    step_functions: /aws/vendedlogs/states/TechAnalysisWorkflow-Logs

secrets:
  jira_connection:
    name_pattern: events!connection/Jira-Connection-${ environment }/*
    description: Auto-created by EventBridge for Jira connection
    managed_by: EventBridge

file_processing:
  supported_file_types: pdf,docx
  max_file_size_mb: 50
  max_retries: 3
  download_timeout_seconds: 120
  s3_upload_prefix: uploads
  max_webhook_body_size_mb: 10

tags:
  Environment: ${ environment }
  Project: ${ project_name }
  Product: ${ product }
  LineOfBusiness: ${ line_of_business }
  StackName: ${ stack_name }
  StackId: ${ stack_id }
  ManagedBy: Terraform
  Owner: Legal-Tech-Team