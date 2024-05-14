require! <[node-fetch]>

# documentation: https://platform.openai.com/docs/api-reference/images/create

sizes =
  "dall-e-2": <[256x256 512x512 1024x1024]>
  "dall-e-3": <[1024x1024 1792x1024 1024x1792]>

/* options:
  key: api key
  model: dall-e-2 or dall-e-3
  prompt: prompt for the image
  n: number of images to generate. 1 for dall-e-3
  size: listed above for different model
  style: vivid or natural
  user: optional user id for preventing abuse
*/
image = (o = {}) ->
  model = o.model or \dall-e-3
  prompt = o.prompt or 'generate a simple, cute and colorful vector style icon for a random stuff'
  n = o.n or 1
  size = o.size or \1024x1024
  style = o.style or \vivid
  if !sizes[model] =>
    return Promise.reject new Error("invalid model. possible options: #{Object.keys sizes .join(', ')}")
  if model == \dall-e-3 and n > 1 =>
    return Promise.reject new Error("only 1 image allowed for dall-e-3")
  if !(size in sizes[model]) =>
    return Promise.reject new Error("invalid size. possible options: #{sizes[model] .join(', ')}")
  if !(style in <[vivid naturl]>) =>
    return Promise.reject new Error("invalid style. possible options: vivid, natural")
  opt =
    method: \POST
    headers:
      "Content-Type": "application/json"
      "Authorization": "Bearer #{o.key}"
    body: JSON.stringify({
      model, prompt, n, size, style, user: o.user
    })
  node-fetch \https://api.openai.com/v1/images/generations, opt
    .then (ret) ->
      if ret.ok => return ret.json!
      (msg) <- ret.text!then _
      Promise.reject((new Error(msg)) <<< {status: ret.status})
    .then (ret) ->
      # stablize and normalize returned result
      return {
        createdtime: (ret.created or Date.now!)
        data: ret.[]data .map (d) -> d{revised_prompt, url}
      }

module.exports = image
