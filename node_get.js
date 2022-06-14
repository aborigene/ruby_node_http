const process = require('process')
const express = require('express')
const http = require('http')
const app = express()
const port = 3000
const options = {
  hostname: '127.0.0.1',
  port: 4567,
  path: '/hello',
  method: 'GET'
}

function runAsyncWrapper (callback) {
  return function (req, res, next) {
    callback(req, res, next)
      .catch(next)
  }
}

app.get('/', runAsyncWrapper(async(req, res) => {
  if (process.uptime()<600){
    const smth = await sleep(3000)      
  }
  console.log(process.uptime())
  const ruby_req = http.request(options, ruby_res => {
    console.log(`statusCode: ${ruby_res.statusCode}`)
    
    res.send('Hello World!')
    ruby_res.on('data', d => {
      process.stdout.write(d)

    })
  })

  ruby_req.on('error', error => {
    console.error(error)
  })

  ruby_req.end()
}))

function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})






