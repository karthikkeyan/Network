const http = require('http');

const hostname = '127.0.0.1';
const port = 3000;

const server = http.createServer((req, res) => {
    if (req.url === "/data/success") {
        res.statusCode = 200;
        res.setHeader('Content-Type', 'application/json');
        res.end('{ "message": "Welcome to Software Engineering with Karthik" }');
        return
    }

    if (req.url === "/upload/failure") {
        res.statusCode = 400;
        res.setHeader('Content-Type', 'application/json');
        res.end('{ "error": "Upload Failed" }');
        return
    }
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});