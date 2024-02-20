const express = require('express');
const cors = require('cors');
const { createProxyMiddleware } = require('http-proxy-middleware');
const { spawn } = require('child_process');
const path = require('path');
const dashboardRoutes = require('./dashboardRoutes');

const app = express();
const port = 2999;

// Dynamic CORS configuration
const corsOptionsDelegate = function (req, callback) {
  var corsOptions;
  const origin = req.header('Origin');
  // Adjust the regex to match your domain structure
  if (origin && /-2999\.proxy\.runpod\.net$/.test(origin)) {
    corsOptions = { origin: true }; // Reflect the request origin in the CORS response
  } else {
    corsOptions = { origin: false }; // Disable CORS for requests that don't match the pattern
  }
  callback(null, corsOptions);
};

// Enable CORS with dynamic origin check
app.use(cors(corsOptionsDelegate));

// Serve static files from the 'public' directory
app.use(express.static(path.join(__dirname, 'public')));

// Proxy middleware options for forwarding requests to tusd
const proxyOptions = {
    target: 'http://localhost:8080', // Target tusd server
    changeOrigin: true,
    onProxyRes: function(proxyRes, req, res) {
        // Modify CORS headers as needed
        proxyRes.headers['Access-Control-Allow-Origin'] = req.header('Origin') || '*';
        proxyRes.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS';
        proxyRes.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept';
    }
};

// Use the proxy middleware for /files route
app.use('/files', createProxyMiddleware(proxyOptions));

app.use(dashboardRoutes);

// Start the tusd server
const tusdBinaryPath = 'tusd'; // Make sure this path is correct
const tusdArgs = [
  '-upload-dir', path.join('/workspace'), // Directory to store uploads
  '-hooks-dir', path.join('/etc/tusd/hooks'), // Directory where hook scripts are located
  '-behind-proxy'
];
const tusd = spawn(tusdBinaryPath, tusdArgs);

tusd.stdout.on('data', (data) => {
    console.log(`tusd stdout: ${data.toString()}`);
});

tusd.stderr.on('data', (data) => {
    console.error(`tusd stderr: ${data.toString()}`);
});

tusd.on('close', (code) => {
    console.log(`tusd process exited with code ${code}`);
});

// Start the Express server
app.listen(port, '0.0.0.0', () => {
    console.log(`Server listening at http://0.0.0.0:${port}`);
});

// Graceful shutdown handling
process.on('SIGINT', () => {
    console.log('Shutting down...');
    tusd.kill();
    process.exit();
});

process.on('SIGTERM', () => {
    console.log('Shutting down...');
    tusd.kill();
    process.exit();
});