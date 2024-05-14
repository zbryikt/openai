api = require "../dist/index"
fs = require "fs-extra"

secret = JSON.parse(fs.read-file-sync "private/secret.json" .toString!)

Promise.resolve!
  .then ->
    opt =
      key: secret.apiKey
      max_tokens: 100
      messages: [{role: 'user', content: "請用正體中文跟我打個招呼"}]
    api.chat opt
  .then -> console.log it
  .then ->
    opt =
      key: secret.apiKey
      prompt: "flying cat"
    api.image opt
  .then -> console.log it



