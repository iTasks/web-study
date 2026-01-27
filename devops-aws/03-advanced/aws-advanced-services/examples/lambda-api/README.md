# Lambda API with DynamoDB

[← Back to Level 3: Advanced](../../../README.md) | [DevOps & AWS](../../../../README.md) | [Main README](../../../../../README.md)

This example demonstrates a serverless REST API using AWS Lambda, API Gateway, and DynamoDB.

## Architecture

```
API Gateway → Lambda Function → DynamoDB
                ↓
              SNS (notifications)
```

## Features

- RESTful API (GET, POST, PUT, DELETE)
- DynamoDB for data storage
- SNS notifications on new items
- CORS enabled
- Error handling and logging

## API Endpoints

### List all items
```bash
curl https://your-api-url/Prod/items
```

### Get specific item
```bash
curl https://your-api-url/Prod/items/{id}
```

### Create item
```bash
curl -X POST https://your-api-url/Prod/items \
  -H "Content-Type: application/json" \
  -d '{"name": "Item 1", "description": "Test item"}'
```

## Cost Estimate

- **Lambda**: First 1M requests/month free
- **API Gateway**: First 1M calls/month free
- **DynamoDB**: First 25 GB storage free
- **SNS**: First 1,000 notifications/month free
