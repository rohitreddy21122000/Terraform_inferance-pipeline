// Simple Lambda to simulate extraction + analysis trigger
exports.handler = async (event) => {
  console.log("Received event:", JSON.stringify(event, null, 2));
  // Input may be HTTP/gateway or Step Function input.
  const filename = event.filename || (event.body && JSON.parse(event.body).filename) || "unknown";
  const document = event.document || (event.body && JSON.parse(event.body).document) || "";
  // Simulate extracted payload
  const extractionResult = {
    success: true,
    filename: filename,
    documentContent: document || "Sample document content for QA"
  };

  // If invoked via API Gateway, return 200 with JSON
  const isApiGateway = !!(event.requestContext || event.httpMethod || event.body);
  if (isApiGateway) {
    return {
      statusCode: 200,
      body: JSON.stringify({ extractionResult })
    };
  }

  // Otherwise Step Function style return
  return {
    extractionResult
  };
};
