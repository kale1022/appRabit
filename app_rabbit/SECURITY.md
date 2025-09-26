# Security Guidelines

## API Key Protection

This project uses environment variables to protect sensitive information like API keys.

### ✅ DO:
- Store API keys in `.env` files
- Add `.env` files to `.gitignore`
- Use `.env.example` as a template
- Never commit API keys to version control

### ❌ DON'T:
- Hardcode API keys in source code
- Commit `.env` files to Git
- Share API keys in documentation or comments
- Use real API keys in examples

## Environment Setup

1. Copy `.env.example` to `.env`
2. Add your actual API key to `.env`
3. Verify `.env` is in `.gitignore`
4. Test that the app works with your key

## Deployment Security

### For Production Deployment:
- Use environment variables provided by your hosting platform
- Never use the same API key for development and production
- Consider using different API keys for different environments
- Monitor API key usage and set up rate limiting

### For CI/CD:
- Store secrets in your CI/CD platform's secret management
- Use environment variables in build scripts
- Never log or expose API keys in build outputs

## Additional Security Measures

- Use HTTPS for all API calls (already implemented)
- Implement rate limiting if needed
- Monitor for unusual API usage
- Rotate API keys periodically
- Use least-privilege API keys when possible
