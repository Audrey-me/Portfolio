// CloudFront Function (viewer request):
//   1. 301 www.<domain> -> <domain>, so search engines see one canonical host.
//   2. Clean URLs: 301 /blog.html -> /blog and /index.html -> /,
//      then serve /blog from blog.html in S3.
function handler(event) {
  var request = event.request;
  var host = request.headers.host && request.headers.host.value;
  var uri = request.uri;

  // 1. www -> apex
  if (host && host.indexOf('www.') === 0) {
    return redirect('https://' + host.substring(4) + cleanPath(uri), request);
  }

  // 2a. Old .html (or trailing-slash) URLs -> clean URL, kept for bookmarks/search results
  var clean = cleanPath(uri);
  if (clean !== uri) {
    return redirect(clean, request);
  }

  // 2b. Clean URL with no file extension -> the .html file in S3
  //     ("/" is left alone; default_root_object serves index.html)
  var last = uri.substring(uri.lastIndexOf('/') + 1);
  if (last !== '' && last.indexOf('.') === -1) {
    request.uri = uri + '.html';
  }

  return request;
}

// /index.html -> /, /blog.html -> /blog, /blog/ -> /blog
function cleanPath(uri) {
  if (uri === '/index.html') return '/';
  if (uri.length > 5 && uri.slice(-5) === '.html') return uri.slice(0, -5);
  if (uri.length > 1 && uri.slice(-1) === '/') return uri.slice(0, -1);
  return uri;
}

function redirect(location, request) {
  var qs = Object.keys(request.querystring)
    .map(function (k) {
      var v = request.querystring[k];
      return v.value ? k + '=' + v.value : k;
    })
    .join('&');

  return {
    statusCode: 301,
    statusDescription: 'Moved Permanently',
    headers: { location: { value: location + (qs ? '?' + qs : '') } },
  };
}
