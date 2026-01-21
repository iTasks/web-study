# IAM Least Privilege Policy Example

This is an example of an IAM policy that follows the principle of least privilege.

## Policy Description

This policy grants minimal permissions needed for an application to:
- List and access objects in a specific S3 bucket
- Only in a specific path (`app/*`)
- Requires server-side encryption
- Allows KMS decryption for S3 service only

## Key Security Features

1. **Resource Restrictions**: Permissions are scoped to specific resources
2. **Path-based Access**: Only allows access to `app/*` path in the bucket
3. **Encryption Requirement**: Enforces AES256 encryption
4. **KMS Conditions**: Limits KMS usage to S3 service only

## Usage

```bash
# Create the policy
aws iam create-policy \
  --policy-name AppS3AccessPolicy \
  --policy-document file://iam-least-privilege.json

# Attach to a role
aws iam attach-role-policy \
  --role-name MyAppRole \
  --policy-arn arn:aws:iam::123456789012:policy/AppS3AccessPolicy
```

## Customization

Replace these values:
- `my-app-bucket` - Your S3 bucket name
- `us-east-1` - Your AWS region
- `123456789012` - Your AWS account ID
- KMS key ID - Your KMS key ARN

## Best Practices Demonstrated

✅ Least privilege principle
✅ Resource-level permissions
✅ Conditional access
✅ Encryption enforcement
✅ Service-scoped KMS access
