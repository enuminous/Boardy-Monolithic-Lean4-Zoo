/* Check the published simulation and its committed Lean snapshot fixtures. */
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const fragment = fs.readFileSync(path.join(__dirname, 'fragment.html'), 'utf8');
const index = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
const scripts = [...fragment.matchAll(/<script>([\s\S]*?)<\/script>/g)];
assert.equal(scripts.length, 1);
const sandbox = {};
vm.runInNewContext(scripts[0][1], sandbox, {timeout: 5000});
const sim = sandbox.EFMWBoardySimulation;
const frames = sim.frames;
const clone = x => JSON.parse(JSON.stringify(x));
assert.equal(frames.length, 13);
assert.deepEqual(clone(frames[4].before), clone(frames[4].state), 'Replay must be a no-op');
assert.equal(frames[4].rejected.length, 1);
assert.equal(frames[5].state.consentA, false);
assert.equal(frames[5].state.consentB, true);
assert.deepEqual(clone(frames.flatMap((f, i) => f.release ? [i] : [])), [6]);
assert.deepEqual(clone(frames.flatMap((f, i) => f.state.booked ? [i] : [])), [11, 12]);
assert.equal(frames[8].action, 'recapPending');
assert.equal(frames[10].state.acceptedB, false);
assert.equal(frames[11].state.epoch, 3);
assert.equal(frames[12].action, 'currentSummary');
assert(frames.some(f => f.receipts.length > 1));
for (const frame of frames) {
  let s = sim.seed();
  for (const event of frame.trace) {
    s = sim.step(s, event);
    assert(!s.booked || (s.consentA && s.consentB && s.acceptedA && s.acceptedB && s.slot !== null));
  }
  assert.deepEqual(clone(s), clone(frame.state));
  assert(frame.receipts.at(-1).ok);
  assert(frame.receipts.length <= 3);
}

// The complete displayed fragment must be embedded in the standalone export.
const encoded = index.match(/data-srcdoc="([\s\S]*?)"/);
assert(encoded, 'Missing standalone simulation frame');
const decoded = encoded[1].replace(/&#x([0-9a-f]+);/gi, (_, n) => String.fromCodePoint(parseInt(n,16)))
  .replace(/&#([0-9]+);/g, (_, n) => String.fromCodePoint(Number(n)))
  .replace(/&quot;/g, '"').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&');
assert(decoded.includes(fragment.trim()), 'Published index and editable simulation diverged');
for (const selector of [...scripts[0][1].matchAll(/q\('\[([^\]]+)\]'\)/g)]) {
  assert(fragment.includes(selector[1]), 'Missing display control: ' + selector[1]);
}

// These expectations come from the actual browser simulation trace; Lean checks
// them independently against ReplayProtected.run, not against the JS function.
const lines = ['import ReplayProtected', 'open ReplayProtected', ''];
const keys = ['consentA','consentB','epoch','slot','acceptedA','acceptedB','booked','consentGenerationA','consentGenerationB'];
for (const f of frames) {
  const events = f.trace.map(e => '.' + e.type + ('value' in e ? ' ' + e.value : '')).join(', ');
  const values = keys.map(k => 's.' + k + ' = ' + (k === 'slot' ? (f.state[k] === null ? 'none' : 'some ' + f.state[k]) : String(f.state[k])));
  lines.push('// Conversation snapshot ' + (f.i + 1), 'example : let s := run {} [' + events + ']', '    ' + values.join(' ∧ ') + ' := by decide', '');
}
const lean = lines.join('\n').replaceAll('// Conversation snapshot', '-- Conversation snapshot');
assert.equal(fs.readFileSync(path.join(root, 'SimulationRegression.lean'), 'utf8'), lean,
  'Lean snapshots do not match the simulation; regenerate and recheck before publishing');
console.log('PASS: 13 simulation exchanges; replay/consent/scheduling checks; recursive review; embedded index and Lean snapshots match.');
