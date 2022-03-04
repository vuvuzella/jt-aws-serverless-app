import { handler } from '../src/index'

describe('Integration testing for handler', () => {

  it('Execute correctly', async () => {
    const result = await handler();
    expect(result).toBe('Hello World');
  })

})
