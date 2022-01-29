import { handler } from '../src/index';

describe('Unit testing for handlser', () => {
  it('Execute correctly', async () => {
    const result = handler();
    expect(result).toBe('Hello World');
  });
});
