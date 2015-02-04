oauth = require 'oauth'
Q = require 'q'
RateLimiter = require('limiter').RateLimiter
querystring = require 'querystring'

class TradeKing
  constructor: (@consumer_key, @consumer_secret, @access_token, @access_secret) ->
    @consumer = new oauth.OAuth null, null, @consumer_key, @consumer_secret, "1.0", null, "HMAC-SHA1"
    @limiter = new RateLimiter(60, 'minute')
    
  get: (url, post_data, stream) ->
    url = "https://api.tradeking.com/v1/"+url+".json?"
    if post_data?
      url += querystring.stringify post_data
    deference = Q.defer()
    @limiter.removeTokens 1, (err, remaining) =>
      @consumer.get url, @access_token, @access_secret, (error, data, response) ->
        if error?
          deference.reject error
        deference.resolve JSON.parse(data)['response']
    return deference.promise

  stream: (url, post_data, stream) ->
    url = "https://stream.tradeking.com/v1/"+url+".json?"
    if post_data?
      url += querystring.stringify post_data
    request = @consumer.get url, @access_token, @access_secret
    request.on 'response', (response) ->
      response.setEncoding 'utf8'
      response.on 'data', (data) ->
        console.log JSON.parse data
    request.end()

  market_clock: =>
    return @get 'market/clock'

  market_quotes: (symbols...) =>
    result = @get  'market/ext/quotes', { "symbols": symbols.join(',') }
    result = result.then (response) ->
      response = response.quotes.quote
      quotes = {}
      if response.length == undefined
        quotes[response.symbol] = response
      else
        for quote in response
          quotes[quote.symbol] = quote
      return quotes
    return result

  market_options_search: =>


  market_options_strikes: =>


  market_options_expirations: =>

  market_quotes_stream: (symbols...) =>
    result = @stream 'market/quotes', { "symbols": symbols.join(',') }
    return result

module.exports = TradeKing
