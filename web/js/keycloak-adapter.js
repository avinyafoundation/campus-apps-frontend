if(window.location.hash) {
    const params = {};
    const requiredParams = ['access_token'];
    const rawParams = (window.location.hash.substring(1)).split("&");
    var rawParam;
    for(rawParam of rawParams) {
      const [key, value] = rawParam.split('=');
      params[key] = value;
    }
    console.log(rawParams);
    if(requiredParams.some((k) => typeof params[k] != 'undefined')) {
      window.localStorage['openid_client:tokens'] = JSON.stringify(params);
    }
  }