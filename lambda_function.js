const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand, GetCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({ region: process.env.AWS_REGION || 'us-east-1' });
const dynamodb = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.TABLE_NAME || 'saybaba-infrastructure-table';

exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  console.log('Table name:', TABLE_NAME);

  const routeKey = event.routeKey || '';

  try {
    // Health check
    if (routeKey.includes('GET /health')) {
      return {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
        body: JSON.stringify({
          status: 'healthy',
          timestamp: new Date().toISOString(),
          service: 'saybaba-serverless-api',
          environment: process.env.ENVIRONMENT,
          uptime: process.uptime(),
        }),
      };
    }

    // Create item
    if (routeKey.includes('POST /items')) {
      return await createItem(event);
    }

    // Get item
    if (routeKey.includes('GET /items/{id}')) {
      return await getItem(event);
    }

    // Not found
    return {
      statusCode: 404,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({ error: 'Route not found', routeKey }),
    };
  } catch (error) {
    console.error('Handler error:', error);
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({
        error: 'Internal server error',
        message: error.message,
        routeKey,
      }),
    };
  }
};

// POST /items - Create item in DynamoDB
const createItem = async (event) => {
  try {
    console.log('Creating item, event body:', event.body);
    const body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;

    const itemId = Date.now().toString();
    const item = {
      PK: `ITEM#${itemId}`,
      SK: itemId,
      id: itemId,
      name: body?.name || 'Unnamed Item',
      description: body?.description || '',
      CreatedAt: new Date().toISOString(),
    };

    console.log('Saving item to DynamoDB:', item);

    await dynamodb.send(new PutCommand({
      TableName: TABLE_NAME,
      Item: item,
    }));

    console.log('Item saved successfully');

    return {
      statusCode: 201,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({
        message: 'Item created successfully',
        id: item.id,
        item: item,
      }),
    };
  } catch (error) {
    console.error('Error creating item:', error);
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({
        error: 'Failed to create item',
        details: error.message,
      }),
    };
  }
};

// GET /items/{id} - Get item from DynamoDB
const getItem = async (event) => {
  try {
    const id = event.rawPath?.split('/').pop() || event.pathParameters?.id;

    if (!id) {
      return {
        statusCode: 400,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
        body: JSON.stringify({ error: 'Item ID is required' }),
      };
    }

    console.log('Getting item with id:', id);

    const result = await dynamodb.send(new GetCommand({
      TableName: TABLE_NAME,
      Key: { PK: `ITEM#${id}`, SK: id },
    }));

    if (!result.Item) {
      return {
        statusCode: 404,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
        body: JSON.stringify({ error: 'Item not found' }),
      };
    }

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify(result.Item),
    };
  } catch (error) {
    console.error('Error retrieving item:', error);
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({ error: 'Failed to retrieve item', details: error.message }),
    };
  }
};
