/**
 * DOZ Taxi - Database Layer (JSON file-based, production-ready structure)
 * In production, replace with PostgreSQL/MySQL
 */
const fs = require('fs');
const path = require('path');

const DB_PATH = path.join(__dirname, 'data');

class Database {
  constructor() {
    if (!fs.existsSync(DB_PATH)) fs.mkdirSync(DB_PATH, { recursive: true });
    this.collections = {};
    this._load('users');
    this._load('drivers');
    this._load('rides');
    this._load('bids');
    this._load('notifications');
  }

  _filePath(name) { return path.join(DB_PATH, `${name}.json`); }

  _load(name) {
    const fp = this._filePath(name);
    if (fs.existsSync(fp)) {
      this.collections[name] = JSON.parse(fs.readFileSync(fp, 'utf8'));
    } else {
      this.collections[name] = [];
      this._save(name);
    }
  }

  _save(name) {
    fs.writeFileSync(this._filePath(name), JSON.stringify(this.collections[name], null, 2));
  }

  find(collection, predicate) {
    return this.collections[collection].filter(predicate);
  }

  findOne(collection, predicate) {
    return this.collections[collection].find(predicate);
  }

  insert(collection, doc) {
    this.collections[collection].push(doc);
    this._save(collection);
    return doc;
  }

  update(collection, predicate, updates) {
    const item = this.collections[collection].find(predicate);
    if (item) {
      Object.assign(item, updates);
      this._save(collection);
    }
    return item;
  }

  count(collection, predicate) {
    if (!predicate) return this.collections[collection].length;
    return this.collections[collection].filter(predicate).length;
  }

  paginate(collection, predicate, page = 1, perPage = 20, sortKey = 'created_at', sortDir = -1) {
    let items = predicate ? this.collections[collection].filter(predicate) : [...this.collections[collection]];
    items.sort((a, b) => sortDir * (new Date(b[sortKey]) - new Date(a[sortKey])));
    const total = items.length;
    const offset = (page - 1) * perPage;
    return { data: items.slice(offset, offset + perPage), total, page, per_page: perPage };
  }
}

module.exports = new Database();
