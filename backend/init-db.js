'use strict';
// First boot: wait for PostgreSQL, then load Worklenz's base schema once.
// An advisory lock stops two overlapping deploys from loading it twice.
const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const SQL_DIR = path.join(__dirname, 'sql');
const FILES = ['0_extensions.sql', '1_tables.sql', 'indexes.sql', '4_functions.sql', 'triggers.sql', '3_views.sql', '2_dml.sql'];
const LOCK_ID = 7319402938;

const cfg = {
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  connectionTimeoutMillis: 10000,
};

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function connect() {
  const deadline = Date.now() + 5 * 60 * 1000;
  for (let attempt = 1; ; attempt++) {
    const client = new Client(cfg);
    try {
      await client.connect();
      return client;
    } catch (err) {
      await client.end().catch(() => {});
      if (Date.now() > deadline) throw err;
      console.log(`[railway] waiting for PostgreSQL (${attempt}): ${err.message}`);
      await sleep(3000);
    }
  }
}

(async () => {
  const client = await connect();
  try {
    await client.query('SELECT pg_advisory_lock($1)', [LOCK_ID]);
    const { rows } = await client.query("SELECT to_regclass('public.users') IS NOT NULL AS ready");
    if (rows[0].ready) {
      console.log('[railway] base schema already present');
      return;
    }
    console.log('[railway] empty database: loading the Worklenz base schema');
    await client.query('BEGIN');
    for (const f of FILES) {
      console.log(`[railway]   ${f}`);
      await client.query(fs.readFileSync(path.join(SQL_DIR, f), 'utf8'));
    }
    await client.query('COMMIT');
    console.log('[railway] base schema loaded');
  } catch (err) {
    await client.query('ROLLBACK').catch(() => {});
    throw err;
  } finally {
    await client.query('SELECT pg_advisory_unlock($1)', [LOCK_ID]).catch(() => {});
    await client.end().catch(() => {});
  }
})().catch((err) => {
  console.error('[railway] database initialisation failed:', err);
  process.exit(1);
});
