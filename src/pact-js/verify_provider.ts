const { Verifier } = require('@pact-foundation/pact');

// (1) Start provider locally. Be sure to stub out any external dependencies
server.listen(8081, () => {
  importData();
  console.log('Animal Profile Service listening on http://localhost:8081');
});

// (2) Verify that the provider meets all consumer expectations
describe('Pact Verification', () => {
  it('validates the expectations of Matching Service', () => {
    let token = 'INVALID TOKEN';

    return new Verifier({
      providerBaseUrl: 'http://localhost:8081', // <- location of your running provider
      pactUrls: [ path.resolve(process.cwd(), "./pacts/SomeConsumer-SomeProvider.json") ],
    })
      .verifyProvider()
      .then(() => {
        console.log('Pact Verification Complete!');
      });
  });
});
