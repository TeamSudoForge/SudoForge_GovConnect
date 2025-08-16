const http = require('http');

// Configuration
const config = {
  host: process.env.DEBUG_HOST || 'localhost',
  port: process.env.DEBUG_PORT || 3000,
  endpoints: [
    '/health',
    '/auth/register',
    '/auth/login',
    '/auth/profile',
    // Add more endpoints to test
  ],
};

console.log(`\n🔍 GovConnect API Debug Tool`);
console.log(`Checking server at http://${config.host}:${config.port}\n`);

// Check server health
const checkServerHealth = () => {
  return new Promise((resolve) => {
    const req = http.request(
      {
        host: config.host,
        port: config.port,
        path: '/health',
        method: 'GET',
        timeout: 5000,
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => {
          data += chunk;
        });

        res.on('end', () => {
          resolve({
            status: res.statusCode,
            data: data.toString(),
          });
        });
      },
    );

    req.on('error', (err) => {
      resolve({
        status: 'ERROR',
        error: err.message,
      });
    });

    req.on('timeout', () => {
      req.destroy();
      resolve({
        status: 'TIMEOUT',
        error: 'Request timed out',
      });
    });

    req.end();
  });
};

// Test all endpoints
const testEndpoint = (path) => {
  return new Promise((resolve) => {
    const req = http.request(
      {
        host: config.host,
        port: config.port,
        path: path,
        method: 'GET',
        timeout: 3000,
      },
      (res) => {
        resolve({
          path,
          status: res.statusCode,
          statusMessage: res.statusMessage,
        });
      },
    );

    req.on('error', (err) => {
      resolve({
        path,
        status: 'ERROR',
        error: err.message,
      });
    });

    req.on('timeout', () => {
      req.destroy();
      resolve({
        path,
        status: 'TIMEOUT',
        error: 'Request timed out',
      });
    });

    req.end();
  });
};

// Run all tests
const runTests = async () => {
  // Check server health
  console.log('Checking server health...');
  const healthCheck = await checkServerHealth();

  if (healthCheck.status !== 200 && healthCheck.status !== 404) {
    console.log('Server appears to be down or unreachable!');
    console.log(`   Error: ${healthCheck.error || 'Unknown error'}`);
    process.exit(1);
  }

  // Test each endpoint
  console.log('\nTesting endpoints:');
  const results = await Promise.all(config.endpoints.map(testEndpoint));

  // Display results
  results.forEach((result) => {
    if (result.status === 404) {
      console.log(` ${result.path} -> 404 Not Found`);
    } else if (result.status >= 200 && result.status < 400) {
      console.log(`${result.path} -> ${result.status} ${result.statusMessage}`);
    } else {
      console.log(
        `${result.path} -> ${result.status} ${result.error || result.statusMessage || ''}`,
      );
    }
  });

  // Summary of findings for 404 errors
  const notFoundRoutes = results.filter((r) => r.status === 404);
  if (notFoundRoutes.length > 0) {
    console.log('\n# Possible issues causing 404 errors:');
    console.log(
      '1. Routes might not be properly registered in your NestJS application',
    );
    console.log(
      '2. Prefix in main.ts might be missing or different (e.g., app.setGlobalPrefix("api"))',
    );
    console.log(
      '3. The controllers might not be included in the correct module',
    );
    console.log('4. Module might not be imported in AppModule');
    console.log('\n# Suggested fixes:');
    console.log('- Check main.ts for any global prefixes');
    console.log(
      '- Ensure all controllers are properly registered in their modules',
    );
    console.log('- Verify module imports in AppModule');
    console.log(
      '- Run the app locally without Docker to see if the issue persists',
    );
  }
};

// Execute the tests
runTests().catch(console.error);
