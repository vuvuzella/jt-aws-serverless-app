import { getVersion } from 'jest'

const message = 'Hello World';

export const handler = () => {
  console.log('Running handler');
  console.log(`Message: ${message}`);
  console.log(`Jest version: ${getVersion()}`);
  return message;
};

export default handler;
