import { helloWorld } from '../src/index';

describe('Integration testing for handlser', () => {

  it('Execute correctly', async () => {
    const result = await helloWorld();
    expect(result.statusCode).toBe(200);
    expect(result.body).toBe('Hello World from Lambda!')
  });

});
