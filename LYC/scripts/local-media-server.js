const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8123;
const ROOT_DIR = path.resolve(__dirname, '..', 'media', 'processed');

const MIME_TYPES = {
  '.mp3': 'audio/mpeg',
  '.m4a': 'audio/mp4'
};

function sendNotFound(res) {
  res.statusCode = 404;
  res.end('Not Found');
}

function sendRangeNotSatisfiable(res, size) {
  res.statusCode = 416;
  res.setHeader('Content-Range', `bytes */${size}`);
  res.end();
}

function parseRangeHeader(rangeHeader, size) {
  if (!rangeHeader || !/^bytes=/.test(rangeHeader)) {
    return null;
  }

  const rangeValue = rangeHeader.replace(/^bytes=/, '').split(',')[0].trim();
  const parts = rangeValue.split('-');

  if (parts.length !== 2) {
    return null;
  }

  const startText = parts[0].trim();
  const endText = parts[1].trim();

  let start;
  let end;

  if (startText === '') {
    const suffixLength = Number(endText);
    if (!Number.isFinite(suffixLength) || suffixLength <= 0) {
      return null;
    }

    start = Math.max(size - suffixLength, 0);
    end = size - 1;
  } else {
    start = Number(startText);
    end = endText === '' ? size - 1 : Number(endText);

    if (!Number.isFinite(start) || !Number.isFinite(end)) {
      return null;
    }
  }

  if (start < 0 || end < start || start >= size) {
    return 'invalid';
  }

  return {
    start: start,
    end: Math.min(end, size - 1)
  };
}

function sendFile(filePath, req, res) {
  fs.stat(filePath, (statError, stat) => {
    if (statError || !stat.isFile()) {
      sendNotFound(res);
      return;
    }

    const ext = path.extname(filePath).toLowerCase();
    const size = stat.size;
    const method = req.method || 'GET';
    const range = parseRangeHeader(req.headers.range, size);

    if (range === 'invalid') {
      sendRangeNotSatisfiable(res, size);
      return;
    }

    let start = 0;
    let end = size - 1;
    let statusCode = 200;

    if (range) {
      start = range.start;
      end = range.end;
      statusCode = 206;
      res.setHeader('Content-Range', `bytes ${start}-${end}/${size}`);
    }

    const contentLength = end - start + 1;

    res.statusCode = statusCode;
    res.setHeader('Content-Type', MIME_TYPES[ext] || 'application/octet-stream');
    res.setHeader('Content-Length', contentLength);
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Accept-Ranges', 'bytes');
    res.setHeader('Cache-Control', 'public, max-age=3600');

    if (method === 'HEAD') {
      res.end();
      return;
    }

    const stream = fs.createReadStream(filePath, {
      start: start,
      end: end
    });
    stream.on('error', () => {
      res.statusCode = 500;
      res.end('Read Error');
    });
    stream.pipe(res);
  });
}

const server = http.createServer((req, res) => {
  const requestPath = decodeURIComponent((req.url || '/').split('?')[0]);
  const relativePath = requestPath.replace(/^\/+/, '');
  const filePath = path.resolve(ROOT_DIR, relativePath);

  if (!filePath.startsWith(ROOT_DIR)) {
    res.statusCode = 403;
    res.end('Forbidden');
    return;
  }

  if (requestPath === '/health') {
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    res.end(JSON.stringify({ ok: true, root: ROOT_DIR }));
    return;
  }

  sendFile(filePath, req, res);
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Local media server listening on http://127.0.0.1:${PORT}`);
  console.log(`Serving ${ROOT_DIR}`);
});
