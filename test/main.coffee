TradeKing = require '../src/tradeking'

chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'

should = chai.should()
expect = chai.expect
chai.use chaiAsPromised

describe 'TradeKing', ->
  before =>
    @client = new TradeKing process.env.TRADEKING_CONSUMER_KEY,
                            process.env.TRADEKING_CONSUMER_SECRET,
                            process.env.TRADEKING_ACCESS_TOKEN,
                            process.env.TRADEKING_ACCESS_SECRET

  it 'fetch a single quote properly', =>
    @client.market_quotes 'AAPL'
      .should.eventually.have.property 'AAPL'

  it 'fetch multiple quotes properly', =>
    quotes = @client.market_quotes 'AAPL', 'MSFT'
    quotes.should.eventually.have.property 'AAPL'
    quotes.should.eventually.have.property 'MSFT'
