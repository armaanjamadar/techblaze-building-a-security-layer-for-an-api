# xAPI

A secure Node.js API designed with advanced security features such as authentication, authorization, input validation, rate limiting, secure error handling, logging, request monitoring and is highly scalable. 

## Team

| Name | Role |
|------|------|
| Abdul Muhaimin | Frontend Developer |
| Tushar Halder | Backend Developer & Product Manager |
| Santosh Joshi | Technical Designer | 

## Quick Start

### 1. Requirements
- node.js
- flutter
- android studio

### 2. Clone the Repository

```bash
git clone https://github.com/armaanjamadar/techblaze-building-a-security-layer-for-an-api.git 
```

### 3. Go to backend folder

### 4.  Run the following comamnds
```bash
npm install
node server
```

## Directory Structure
```
xAPI/
│
├── backend/              # Node.js backend API
│   ├── server.js
│   ├── package.json
│   └── ...
│
├── frontend/             # Flutter frontend application
│   ├── lib/
│   ├── pubspec.yaml
│   └── ...
│
└── README.md
```

## Security Features

The API implements the following security features:

- Authentication – Verifies the identity of users.
- Authorization – Controls access to protected resources.
- Input Validation – Validates and sanitizes incoming data.
- Rate Limiting – Limits excessive API requests and helps prevent abuse.
- Secure Error Handling – Prevents sensitive information from being exposed through error messages.
- Logging - Keeps record of all the requests
- Request Monitoring – Tracks API activity for monitoring and security analysis.

### Handling Vulnerabilities
- To only allow legitimate requests
- To prevent malicious or abusive requests

## Technology Stack
### Frontend
- Flutter
- Dart
### Backend
- node.js
- express.js

## Resources
- Flutter https://docs.flutter.dev/install/quick
- Node.js https://nodejs.org/docs/latest/api/
- express.js https://expressjs.com/en/5x/starter/installing/

## Conclusion
The purpose of xAPI is to demonstrate how a security layer can be implemented around an API to protect it against common security weaknesses and abusive requests.
