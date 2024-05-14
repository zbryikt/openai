require! <[node-fetch]>

# documentation: https://platform.openai.com/docs/api-reference/chat/create

/* options:
  key: api key
  model: gpt-4o, gpt-4-turbo, gpt-3.5-turbo, etc.
   - see also: https://platform.openai.com/docs/models/gpt-4-turbo-and-gpt-4
  message: message to chat
  temperature: 0 ~ 2. 
  response_format: optional. setting to `{ "type": "json_object" }` to guarantee JSON response
   - type can be either `text` or `json_object`
   - you must also instruct the model to produce JSON yourself via a system or user message
  max_tokens: maximum number of tokens that can be generated in the chat completion. optional
  seed: integer seed for determination. optional
  user: optional user id for preventing abuse
  frequency_penalty, logit_bias, logprobs, top_logprobs, presence_penalty, stop, stream, stream_options,
  tool_choice, tools, top_p: TBD
*/

chat = (o = {}) ->
  model = o.model or \gpt-4o
  messages = o.messages or [{role: \user, content: 'hello there'}]
  temperature = o.temperature or 0.8
  opt =
    method: \POST
    headers:
      "Content-Type": "application/json"
      "Authorization": "Bearer #{o.key}"
    body: JSON.stringify({
      model, messages, temperature
      seed: o.seed, user: o.user, response_format: o.response_format
      max_tokens: o.max_tokens
    })
  node-fetch \https://api.openai.com/v1/chat/completions, opt
    .then (ret) ->
      if ret.ok => return ret.json!
      (msg) <- ret.text!then _
      Promise.reject((new Error(msg)) <<< {status: ret.status})
    .then (ret) ->
      # stablize and normalize returned result
      {raw: ret, message: (ret.[]choices.0 or {}).message.content}

module.exports = chat
