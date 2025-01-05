import readline from 'readline';
import bs58 from 'bs58';

// Create a readline interface for user input
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

// Function to validate and parse the private key array
function askForPrivateKey(): void {
  rl.question('Enter your private key as an array of numbers (e.g., [1,2,3,...]): ', (input) => {
    try {
      // Parse the input as JSON
      const privateKeyArray = JSON.parse(input);

      // Validate that it's an array of numbers
      if (
        !Array.isArray(privateKeyArray) ||
        !privateKeyArray.every((num) => Number.isInteger(num) && num >= 0 && num <= 255)
      ) {
        throw new Error('Invalid input: Please enter an array of numbers between 0 and 255.');
      }

      // Convert the array to a Buffer
      const privateKeyBuffer = Buffer.from(privateKeyArray);

      // Encode the buffer to a Base58 string
      const privateKeyBase58 = bs58.encode(privateKeyBuffer);

      console.log('Base58 Encoded Private Key:', privateKeyBase58);
    } catch (error) {
      if (error instanceof Error) {
        console.error('Error:', error.message);
      } else {
        console.error('An unexpected error occurred.');
      }
      askForPrivateKey(); // Retry on invalid input
    } finally {
      rl.close();
    }
  });
}

// Start the prompt
askForPrivateKey();
