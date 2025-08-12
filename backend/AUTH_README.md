# GovConnect Backend - Authentication System

A NestJS-based backend API with comprehensive authentication features including email/password login, registration, JWT tokens, refresh tokens, and WebAuthn passkeys.

## Features

- Email/Password Registration
- Email/Password Login
- JWT Access Tokens
- Refresh Tokens
- Passkey Registration (WebAuthn)
- Passkey Authentication
- User Profile Management
- Secure Password Hashing (bcrypt)
- PostgreSQL Database with TypeORM
- Input Validation
- Environment Configuration

## Prerequisites

- Node.js (v18 or higher)
- PostgreSQL database
- npm or yarn

## Installation

1. Install dependencies:
```bash
npm install
```

2. Set up your environment variables by copying `.env.example` to `.env`:
```bash
cp .env.example .env
```

3. Update the `.env` file with your database credentials and other configuration.

4. Make sure your PostgreSQL database is running and accessible.

5. Start the application in development mode:
```bash
npm run start:dev
```

The server will start on `http://localhost:3000` (or the port specified in your `.env` file).

## API Endpoints

### Authentication

#### Register
```http
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe",
  "username": "johndoe"
}
```

**Response:**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "username": "johndoe",
    "firstName": "John",
    "lastName": "Doe",
    "role": "user"
  },
  "accessToken": "jwt-token",
  "refreshToken": "uuid"
}
```

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "username": "johndoe",
    "firstName": "John",
    "lastName": "Doe",
    "role": "user"
  },
  "accessToken": "jwt-token",
  "refreshToken": "uuid"
}
```

#### Refresh Token
```http
POST /auth/refresh
Content-Type: application/json

{
  "refreshToken": "your-refresh-token"
}
```

#### Get Profile
```http
GET /auth/profile
Authorization: Bearer <access-token>
```

### Passkey Authentication

#### Begin Passkey Registration
```http
POST /auth/passkey/register/begin
Authorization: Bearer <access-token>
Content-Type: application/json

{
  "displayName": "My Phone"
}
```

#### Complete Passkey Registration
```http
POST /auth/passkey/register/complete
Authorization: Bearer <access-token>
Content-Type: application/json

{
  "displayName": "My Phone",
  "id": "credential-id",
  "response": {
    // WebAuthn credential response
  }
}
```

#### Begin Passkey Authentication
```http
POST /auth/passkey/authenticate/begin
```

#### Complete Passkey Authentication
```http
POST /auth/passkey/authenticate/complete
Content-Type: application/json

{
  "id": "credential-id",
  "response": {
    // WebAuthn authentication response
  }
}
```

#### Get User Passkeys
```http
GET /auth/passkeys
Authorization: Bearer <access-token>
```

#### Delete Passkey
```http
DELETE /auth/passkeys/:id
Authorization: Bearer <access-token>
```

## Database Schema

The application uses three main entities:

### Users
- `id` (UUID, Primary Key)
- `email` (Unique)
- `username` (Unique)
- `passwordHash`
- `firstName`
- `lastName`
- `role`
- `createdAt`
- `updatedAt`

### AuthSessions
- `id` (UUID, Primary Key)
- `userId` (Foreign Key)
- `refreshToken`
- `expiresAt`
- `createdAt`

### Passkeys
- `id` (UUID, Primary Key)
- `userId` (Foreign Key)
- `credentialId`
- `credentialPublicKey`
- `credentialCounter`
- `credentialDeviceType`
- `credentialBackedUp`
- `transports`
- `displayName`
- `createdAt`
- `updatedAt`

## Security Features

1. **Password Security**: Passwords are hashed using bcrypt with configurable rounds
2. **JWT Security**: Access tokens have short expiration times (15 minutes by default)
3. **Refresh Tokens**: Stored securely in database with expiration
4. **Input Validation**: All inputs are validated using class-validator
5. **WebAuthn Support**: Modern passwordless authentication
6. **Environment Configuration**: Sensitive data stored in environment variables

## Development

### Running the app
```bash
# development
npm run start

# watch mode
npm run start:dev

# production mode
npm run start:prod
```

### Testing
```bash
# unit tests
npm run test

# e2e tests
npm run test:e2e

# test coverage
npm run test:cov
```

### Linting
```bash
# lint and fix
npm run lint
```

### Building
```bash
npm run build
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Application port | `3000` |
| `NODE_ENV` | Environment mode | `development` |
| `DB_HOST` | Database host | `localhost` |
| `DB_PORT` | Database port | `5432` |
| `DB_USERNAME` | Database username | `postgres` |
| `DB_PASSWORD` | Database password | `password` |
| `DB_NAME` | Database name | `govconnect` |
| `JWT_SECRET` | JWT secret key | Required |
| `JWT_EXPIRES_IN` | Access token expiration | `15m` |
| `JWT_REFRESH_EXPIRES_IN` | Refresh token expiration | `7d` |
| `BCRYPT_ROUNDS` | Password hashing rounds | `12` |
| `RP_NAME` | WebAuthn RP name | `GovConnect` |
| `RP_ID` | WebAuthn RP ID | `localhost` |
| `ORIGIN` | Application origin | `http://localhost:3000` |

## Error Handling

The API returns appropriate HTTP status codes and error messages:

- `400 Bad Request`: Invalid input data
- `401 Unauthorized`: Invalid credentials or token
- `403 Forbidden`: Access denied
- `404 Not Found`: Resource not found
- `409 Conflict`: Resource already exists (e.g., email taken)
- `500 Internal Server Error`: Server error

Error responses follow this format:
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "error": "Bad Request"
}
```

## Technology Stack

- **Framework**: NestJS
- **Database**: PostgreSQL with TypeORM
- **Authentication**: JWT, Passport, WebAuthn
- **Validation**: class-validator
- **Password Hashing**: bcryptjs
- **Environment**: @nestjs/config

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the UNLICENSED license.
