import { getVersion } from 'jest'

const message = 'Hello World';

export const myFunction = async () => {
  return Promise.resolve(message)
}

export const handler = async () => {
  console.log('Running handler');
  console.log(`Message: ${message}`);
  console.log(`Jest version: ${getVersion()}`);
  return await myFunction();
};

export default handler;
