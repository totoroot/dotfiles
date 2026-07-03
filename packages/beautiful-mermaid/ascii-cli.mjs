import fs from 'node:fs';
import { renderMermaidAscii } from './dist/index.js';

const chunks = [];
for await (const chunk of process.stdin) chunks.push(chunk);
const text = Buffer.concat(chunks.map(c => Buffer.isBuffer(c) ? c : Buffer.from(c))).toString('utf8');
process.stdout.write(renderMermaidAscii(text));
process.stdout.write('\n');
