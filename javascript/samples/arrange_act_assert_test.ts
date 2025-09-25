import { PactV3, MatchersV3 } from '@pact-foundation/pact';

// Create a 'pact' between the two applications in the integration we are testing
const provider = new PactV3({
  dir: path.resolve(process.cwd(), 'pacts'),
  consumer: 'MyConsumer',
  provider: 'MyProvider',
});

// API Client that will fetch dogs from the Dog API
// This is the target of our Pact test
public getMeDogs = (from: string): AxiosPromise => {
  return axios.request({
    baseURL: this.url,
    params: { from },
    headers: { Accept: 'application/json' },
    method: 'GET',
    url: '/dogs',
  });
};

const dogExample = { dog: 1 };
const EXPECTED_BODY = MatchersV3.eachLike(dogExample);

describe('GET /dogs', () => {
  it('returns an HTTP 200 and a list of docs', () => {
    // Arrange: Setup our expected interactions
    //
    // We use Pact to mock out the backend API
    provider
      .given('I have a list of dogs')
      .uponReceiving('a request for all dogs with the builder pattern')
      .withRequest({
        method: 'GET',
        path: '/dogs',
        query: { from: 'today' },
        headers: { Accept: 'application/json' },
      })
      .willRespondWith({
        status: 200,
        headers: { 'Content-Type': 'application/json' },
        body: EXPECTED_BODY,
      });

    return provider.executeTest((mockserver) => {
      // Act: test our API client behaves correctly
      //
      // Note we configure the DogService API client dynamically to 
      // point to the mock service Pact created for us, instead of 
      // the real one
      dogService = new DogService(mockserver.url);
      const response = await dogService.getMeDogs('today')

      // Assert: check the result
      expect(response.data[0]).to.deep.eq(dogExample);
    });
  });
});
