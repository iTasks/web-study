const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();

const params = {
  TableName : 'your-table-name',
  Key: 'row-key'
}

exports.handler = async (event, context) => {
  try {
    const data = await docClient.scan(params).promise()
    return { body: JSON.stringify(data) }
  } catch (err) {
    return { error: err }
  }
}
