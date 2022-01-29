const message = 'Hello World';

export const handler = () => {
  console.log('Running handler');
  console.log(`Message: ${message}`);
  return message;
};

export default handler;
