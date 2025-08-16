# GovConnect Backend

NestJS-based authentication backend with comprehensive user management and security features.

## Prerequisites

- Docker and Docker Compose installed
- Node.js (for npm scripts)

## Quick Start

### Start Development Environment

```bash
npm run docker:dev
```

This starts all essential services:

- Backend API (http://localhost:3000)
- PostgreSQL Database
- MinIO File Storage (http://localhost:9001)
- MailHog Email Testing (http://localhost:8025)
- Redis Cache

### Check Services

```bash
npm run docker:status
```

### View Logs

```bash
npm run docker:dev:logs
```

### Stop Services

```bash
npm run docker:dev:stop
```

## Test Authentication

### Health Check

```bash
curl http://localhost:3000/health
```

### Register User

```bash
curl -X POST http://localhost:3000/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com","password":"password123","firstName":"John","lastName":"Doe","username":"johndoe"}'
```

### Login

```bash
curl -X POST http://localhost:3000/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Two-Factor Authentication

When a user with enabled 2FA logs in, the system automatically sends a verification code to the user's email address. The login process will then require this verification code to complete authentication.

#### Enable 2FA for a User

```bash
curl -X POST http://localhost:3000/auth/enable-2fa \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  -H 'Content-Type: application/json'
```

#### Complete Login with 2FA

```bash
curl -X POST http://localhost:3000/auth/verify-2fa \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com","verificationCode":"123456"}'
```

## Documentation

- **Authentication API**: `AUTH_README.md`
- **Docker Setup**: `DOCKER_SIMPLIFIED.md`
- **Test Interface**: `test-frontend.html`

## Features

- Email/Password Authentication
- JWT Token Management
- WebAuthn Passkey Support
- Password Hashing (bcrypt)
- Input Validation
- Health Monitoring
- Docker Containerization
- File Storage (MinIO)
- Email Testing (MailHog)
- Database Management (PostgreSQL)

## Ready to Code!

Your authentication backend is now running with all essential services. Start building your features!

## Project setup

```bash
$ npm install
```

## Compile and run the project

```bash
# development
$ npm run start

# watch mode
$ npm run start:dev

# production mode
$ npm run start:prod
```

## Run tests

```bash
# unit tests
$ npm run test

# e2e tests
$ npm run test:e2e

# test coverage
$ npm run test:cov
```

## Deployment

When you're ready to deploy your NestJS application to production, there are some key steps you can take to ensure it runs as efficiently as possible. Check out the [deployment documentation](https://docs.nestjs.com/deployment) for more information.

If you are looking for a cloud-based platform to deploy your NestJS application, check out [Mau](https://mau.nestjs.com), our official platform for deploying NestJS applications on AWS. Mau makes deployment straightforward and fast, requiring just a few simple steps:

```bash
$ npm install -g @nestjs/mau
$ mau deploy
```

With Mau, you can deploy your application in just a few clicks, allowing you to focus on building features rather than managing infrastructure.

## Resources

Check out a few resources that may come in handy when working with NestJS:

- Visit the [NestJS Documentation](https://docs.nestjs.com) to learn more about the framework.
- For questions and support, please visit our [Discord channel](https://discord.gg/G7Qnnhy).
- To dive deeper and get more hands-on experience, check out our official video [courses](https://courses.nestjs.com/).
- Deploy your application to AWS with the help of [NestJS Mau](https://mau.nestjs.com) in just a few clicks.
- Visualize your application graph and interact with the NestJS application in real-time using [NestJS Devtools](https://devtools.nestjs.com).
- Need help with your project (part-time to full-time)? Check out our official [enterprise support](https://enterprise.nestjs.com).
- To stay in the loop and get updates, follow us on [X](https://x.com/nestframework) and [LinkedIn](https://linkedin.com/company/nestjs).
- Looking for a job, or have a job to offer? Check out our official [Jobs board](https://jobs.nestjs.com).

## Support

Nest is an MIT-licensed open source project. It can grow thanks to the sponsors and support by the amazing backers. If you'd like to join them, please [read more here](https://docs.nestjs.com/support).

## Stay in touch

- Author - [Kamil Myśliwiec](https://twitter.com/kammysliwiec)
- Website - [https://nestjs.com](https://nestjs.com/)
- Twitter - [@nestframework](https://twitter.com/nestframework)

## License

Nest is [MIT licensed](https://github.com/nestjs/nest/blob/master/LICENSE).
