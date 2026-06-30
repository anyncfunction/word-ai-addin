const http = require('http')
const https = require('https')
const fs = require('fs')
const path = require('path')

const PORT = 3000
const rootDir = (() => {
  const candidates = [
    path.dirname(process.execPath),
    path.join(path.dirname(process.execPath), '..'),
    __dirname,
    process.cwd(),
  ]
  for (const dir of candidates) {
    try {
      if (fs.existsSync(path.join(dir, 'manifest.xml'))) return dir
    } catch {}
  }
  return path.dirname(process.execPath)
})()
const logPath = path.join(rootDir, 'server.log')
const distDir = path.join(rootDir, 'dist')
const assetsDir = path.join(rootDir, 'assets')

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
  '.xml': 'application/xml',
}

function log(msg) {
  const line = `[${new Date().toISOString()}] ${msg}`
  console.log(line)
  try { fs.appendFileSync(logPath, line + '\n') } catch {}
}

function serveFile(res, filePath) {
  const ext = path.extname(filePath)
  res.writeHead(200, { 'Content-Type': MIME[ext] || 'application/octet-stream' })
  fs.createReadStream(filePath).pipe(res)
}

function notFound(res) {
  res.writeHead(404, { 'Content-Type': 'text/plain' })
  res.end('404 Not Found')
}

function handler(req, res) {
  let url = req.url.split('?')[0]

  // 健康检查
  if (url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' })
    res.end(JSON.stringify({ ok: true, uptime: process.uptime() }))
    return
  }

  // manifest.xml
  if (url === '/manifest.xml') {
    const p = path.join(rootDir, 'manifest.xml')
    if (fs.existsSync(p)) return serveFile(res, p)
    return notFound(res)
  }

  // 静态文件
  let searchPaths = []

  if (url.startsWith('/assets/')) {
    searchPaths.push(path.join(assetsDir, url.slice(8)))
  } else {
    searchPaths.push(path.join(distDir, url))
    if (url.endsWith('/')) searchPaths.push(path.join(distDir, url, 'index.html'))
    if (!path.extname(url)) searchPaths.push(path.join(distDir, url + '.html'))
  }

  for (const p of searchPaths) {
    if (fs.existsSync(p) && fs.statSync(p).isFile()) {
      return serveFile(res, p)
    }
  }

  notFound(res)
}

log('🚀 AI 写作助手服务器启动中...')

const server = http.createServer(handler)

server.listen(PORT, () => {
  log(`🔓 HTTP 服务器已启动: http://localhost:${PORT}`)
  log(`📋 manifest: http://localhost:${PORT}/manifest.xml`)
})

process.on('uncaughtException', (err) => log(`💥 错误: ${err.message}`))
process.on('unhandledRejection', (err) => log(`💥 错误: ${err}`))
