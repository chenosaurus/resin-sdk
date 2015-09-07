m = require('mochainon')
nock = require('nock')
Promise = require('bluebird')
settings = require('../../lib/settings')
os = require('../../lib/models/os')
johnDoeFixture = require('../tokens.json').johndoe

describe 'OS Model:', ->

	describe 'given a /whoami endpoint', ->

		beforeEach (done) ->
			settings.get('apiUrl').then (apiUrl) ->
				nock(apiUrl).get('/whoami').reply(200, johnDoeFixture.token)
				done()

		afterEach ->
			nock.cleanAll()

		describe '.download()', ->

			describe 'given valid parameters', ->

				beforeEach (done) ->
					settings.get('apiUrl').then (apiUrl) ->
						nock(apiUrl).get('/download?network=ethernet&appId=95')
							.reply(200, 'Lorem ipsum dolor sit amet')
						done()

				afterEach ->
					nock.cleanAll()

				it 'should stream the download', (done) ->
					os.download
						network: 'ethernet'
						appId: 95
					.then (stream) ->
						result = ''
						stream.on 'data', (chunk) -> result += chunk
						stream.on 'end', ->
							m.chai.expect(result).to.equal('Lorem ipsum dolor sit amet')
							done()

				it 'should stream the download after a slight delay', (done) ->
					os.download
						network: 'ethernet'
						appId: 95
					.then (stream) ->
						return Promise.delay(200).return(stream)
					.then (stream) ->
						result = ''
						stream.on 'data', (chunk) -> result += chunk
						stream.on 'end', ->
							m.chai.expect(result).to.equal('Lorem ipsum dolor sit amet')
							done()

			describe 'given invalid parameters', ->

				beforeEach (done) ->
					settings.get('apiUrl').then (apiUrl) ->
						nock(apiUrl).get('/download?network=ethernet&appId=95')
							.reply(400, 'Invalid application name')
						done()

				afterEach ->
					nock.cleanAll()

				it 'should be rejected with an error message', ->
					promise = os.download
						network: 'ethernet'
						appId: 95

					m.chai.expect(promise).to.be.rejectedWith('Invalid application name')
