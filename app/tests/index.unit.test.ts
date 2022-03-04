import { myFunction } from '../src/index';

describe('Unit testing for handlser', () => {

  it('Execute correctly', async () => {
    const result = await myFunction();
    expect(result).toBe('Hello World');
  });

});
