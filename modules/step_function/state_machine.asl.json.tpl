{
  "Comment": "${comment}",
  "StartAt": "ExtractText",
  "States": {
    "ExtractText": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${lambda_arn}",
        "Payload.$": "$"
      },
      "ResultPath": "$.extractionResult",
      "Next": "ValidateExtraction",
      "Catch": [
        {
          "ErrorEquals": ["States.ALL"],
          "ResultPath": "$.errorInfo",
          "Next": "FormatError"
        }
      ]
    },
    "ValidateExtraction": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.extractionResult.Payload.success",
          "BooleanEquals": true,
          "Next": "FormatSuccess"
        }
      ],
      "Default": "FormatError"
    },
    "FormatSuccess": {
      "Type": "Pass",
      "ResultPath": "$.final",
      "Parameters": {
        "message": "Document processed successfully",
        "filename.$": "$.extractionResult.Payload.filename",
        "documentContent.$": "$.extractionResult.Payload.documentContent"
      },
      "End": true
    },
    "FormatError": {
      "Type": "Pass",
      "ResultPath": "$.final",
      "Parameters": {
        "message": "Document processing failed",
        "error.$": "$.errorInfo"
      },
      "End": true
    }
  }
}
