// Removed node-fetch require to avoid dependency issues
// If node-fetch is not available, we can use http module, but let's try native fetch first if node > 18.
// Since I don't know the node version, I'll use the 'http' module to be safe and dependency-free.

const http = require('http');

const data = JSON.stringify({
    email: 'admin@hoyspace.com',
    password: 'admin123'
});

const options = {
    hostname: 'localhost',
    port: 5000,
    path: '/api/auth/login',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
    }
};

const req = http.request(options, (res) => {
    let responseBody = '';

    console.log(`Status Code: ${res.statusCode}`);

    res.on('data', (chunk) => {
        responseBody += chunk;
    });

    res.on('end', () => {
        console.log('Response Body:', responseBody);
    });
});

req.on('error', (error) => {
    console.error('Error:', error);
});

req.write(data);
req.end();
