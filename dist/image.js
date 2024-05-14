var nodeFetch, sizes, image;
nodeFetch = require('node-fetch');
sizes = {
  "dall-e-2": ['256x256', '512x512', '1024x1024'],
  "dall-e-3": ['1024x1024', '1792x1024', '1024x1792']
};
/* options:
  key: api key
  model: dall-e-2 or dall-e-3
  prompt: prompt for the image
  n: number of images to generate. 1 for dall-e-3
  size: listed above for different model
  style: vivid or natural
  user: optional user id for preventing abuse
*/
image = function(o){
  var model, prompt, n, size, style, opt;
  o == null && (o = {});
  model = o.model || 'dall-e-3';
  prompt = o.prompt || 'generate a simple, cute and colorful vector style icon for a random stuff';
  n = o.n || 1;
  size = o.size || '1024x1024';
  style = o.style || 'vivid';
  if (!sizes[model]) {
    return Promise.reject(new Error("invalid model. possible options: " + Object.keys(sizes).join(', ')));
  }
  if (model === 'dall-e-3' && n > 1) {
    return Promise.reject(new Error("only 1 image allowed for dall-e-3"));
  }
  if (!in$(size, sizes[model])) {
    return Promise.reject(new Error("invalid size. possible options: " + sizes[model].join(', ')));
  }
  if (!(style === 'vivid' || style === 'naturl')) {
    return Promise.reject(new Error("invalid style. possible options: vivid, natural"));
  }
  opt = {
    method: 'POST',
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + o.key
    },
    body: JSON.stringify({
      model: model,
      prompt: prompt,
      n: n,
      size: size,
      style: style,
      user: o.user
    })
  };
  return nodeFetch('https://api.openai.com/v1/images/generations', opt).then(function(ret){
    if (ret.ok) {
      return ret.json();
    }
    return ret.text().then(function(msg){
      var ref$;
      return Promise.reject((ref$ = new Error(msg), ref$.status = ret.status, ref$));
    });
  }).then(function(ret){
    return {
      createdtime: ret.created || Date.now(),
      data: (ret.data || (ret.data = [])).map(function(d){
        return {
          revised_prompt: d.revised_prompt,
          url: d.url
        };
      })
    };
  });
};
module.exports = image;
function in$(x, xs){
  var i = -1, l = xs.length >>> 0;
  while (++i < l) if (x === xs[i]) return true;
  return false;
}
