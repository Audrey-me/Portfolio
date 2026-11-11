// CloudFront Function (viewer request): 301 www.<domain> -> <domain>,
// so search engines see one canonical host.
function handler(event) {
  var request = event.request;
  var host = request.headers.host && request.headers.host.value;

  if (host && host.indexOf('www.') === 0) {
    var qs = Object.keys(request.querystring)
      .map(function (k) {
        var v = request.querystring[k];
        return v.value ? k + '=' + v.value : k;
      })
      .join('&');

    return {
      statusCode: 301,
      statusDescription: 'Moved Permanently',
      headers: {
        location: { value: 'https://' + host.substring(4) + request.uri + (qs ? '?' + qs : '') },
      },
    };
  }

  return request;
}
