// Simple Lambda function for API Gateway
// This is a health check endpoint

exports.handler = async (event) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  // Health check response
  const response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
    body: JSON.stringify({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      service: 'saybaba-serverless-api',
      environment: process.env.ENVIRONMENT,
      uptime: process.uptime(),
    }),
  };

  return response;
};

// Additional Lambda function examples

// POST function to create item in DynamoDB
exports.createItem = async (event, context) => {
  const AWS = require('aws-sdk');
  const dynamodb = new AWS.DynamoDB.DocumentClient();

  try {
    const body = JSON.parse(event.body);

    const item = {
      PK: `USER#${Date.now()}`,
      SK: `ITEM#${Date.now()}`,
      ...body,
      CreatedAt: new Date().toISOString(),
    };

    await dynamodb.put({
      TableName: process.env.TABLE_NAME,
      Item: item,
    }).promise();

    return {
      statusCode: 201,
      body: JSON.stringify({ message: 'Item created', id: item.PK }),
    };
  } catch (error) {
    console.error('Error creating item:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Failed to create item' }),
    };
  }
};

// GET function to retrieve item from DynamoDB
exports.getItem = async (event) => {
  const AWS = require('aws-sdk');
  const dynamodb = new AWS.DynamoDB.DocumentClient();

  try {
    const { id } = event.pathParameters;

    const result = await dynamodb.get({
      TableName: process.env.TABLE_NAME,
      Key: { PK: id },
    }).promise();

    if (!result.Item) {
      return {
        statusCode: 404,
        body: JSON.stringify({ error: 'Item not found' }),
      };
    }

    return {
      statusCode: 200,
      body: JSON.stringify(result.Item),
    };
  } catch (error) {
    console.error('Error retrieving item:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Failed to retrieve item' }),
    };
  }
};
