const fs = require('fs');
const zlib = require('zlib');
const [file, version] = process.argv.slice(2);
if (!file || !version) throw new Error('Usage: node check-swf-version.js <file> <version>');
const bytes = fs.readFileSync(file);
const signature = bytes.subarray(0, 3).toString('ascii');
const body = signature === 'CWS' ? zlib.inflateSync(bytes.subarray(8)) : bytes.subarray(8);
if (!['CWS', 'FWS'].includes(signature) || !body.includes(Buffer.from(version))) {
  throw new Error(`${file} does not contain version ${version}`);
}
console.log(`${file}: ${version}`);
