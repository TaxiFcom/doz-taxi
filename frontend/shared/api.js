/**
 * DOZ Taxi - Shared API Client & Utilities
 */

// ===== CONFIG =====
const API_BASE = window.location.origin + '/api/v1';
const WS_BASE = 'ws://' + window.location.host + '/ws';

// ===== TOKEN MANAGEMENT =====
const Auth = {
  getToken: () => localStorage.getItem('doz_token'),
  getUser: () => { try { return JSON.parse(localStorage.getItem('doz_user')); } catch { return null; } },
  save: (token, user) => { localStorage.setItem('doz_token', token); localStorage.setItem('doz_user', JSON.stringify(user)); },
  clear: () => { localStorage.removeItem('doz_token'); localStorage.removeItem('doz_user'); },
  isLoggedIn: () => !!localStorage.getItem('doz_token'),
  requireRole: (role) => {
    const user = Auth.getUser();
    if (!user || user.role !== role) { window.location.href = '/'; return false; }
    return true;
  }
};

// ===== API CLIENT =====
const API = {
  async request(method, path, body = null) {
    const headers = { 'Content-Type': 'application/json' };
    const token = Auth.getToken();
    if (token) headers['Authorization'] = 'Bearer ' + token;
    const opts = { method, headers };
    if (body) opts.body = JSON.stringify(body);
    const res = await fetch(API_BASE + path, opts);
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || 'Request failed');
    return data.data;
  },
  get: (path) => API.request('GET', path),
  post: (path, body) => API.request('POST', path, body),
  put: (path, body) => API.request('PUT', path, body),
  delete: (path) => API.request('DELETE', path),
};

// ===== WEBSOCKET CLIENT =====
let ws = null;
let wsHandlers = {};
let wsReconnectTimer = null;

const WS = {
  connect() {
    const token = Auth.getToken();
    if (!token) return;
    if (ws && ws.readyState === WebSocket.OPEN) return;
    ws = new WebSocket(WS_BASE + '?token=' + token);
    ws.onmessage = (e) => {
      try {
        const { type, payload } = JSON.parse(e.data);
        if (wsHandlers[type]) wsHandlers[type].forEach(fn => fn(payload));
        if (wsHandlers['*']) wsHandlers['*'].forEach(fn => fn({ type, payload }));
      } catch {}
    };
    ws.onclose = () => {
      wsReconnectTimer = setTimeout(() => WS.connect(), 3000);
    };
    ws.onerror = () => ws.close();
  },
  on(event, fn) { if (!wsHandlers[event]) wsHandlers[event] = []; wsHandlers[event].push(fn); },
  off(event, fn) { if (wsHandlers[event]) wsHandlers[event] = wsHandlers[event].filter(f => f !== fn); },
  disconnect() { if (wsReconnectTimer) clearTimeout(wsReconnectTimer); if (ws) ws.close(); }
};

// ===== UI UTILITIES =====
const UI = {
  toast(msg, type = 'default', duration = 3000) {
    let container = document.getElementById('toast-container');
    if (!container) { container = document.createElement('div'); container.id = 'toast-container'; document.body.appendChild(container); }
    const toast = document.createElement('div');
    const icons = { success: '✅', danger: '❌', warning: '⚠️', default: 'ℹ️' };
    toast.className = `toast toast-${type}`;
    toast.innerHTML = `<span>${icons[type] || 'ℹ️'}</span><span>${msg}</span>`;
    container.appendChild(toast);
    setTimeout(() => { toast.style.opacity = '0'; toast.style.transform = 'translateY(-10px)'; toast.style.transition = 'all 0.3s'; setTimeout(() => toast.remove(), 300); }, duration);
  },
  loading(show, msg = 'جاري التحميل...') {
    let overlay = document.getElementById('loading-overlay');
    if (show) {
      if (!overlay) { overlay = document.createElement('div'); overlay.id = 'loading-overlay'; overlay.className = 'loading-overlay'; overlay.innerHTML = `<div style="text-align:center"><div class="spinner" style="width:40px;height:40px;margin:0 auto 1rem"></div><p style="color:var(--gray)">${msg}</p></div>`; document.body.appendChild(overlay); }
    } else { if (overlay) overlay.remove(); }
  },
  confirm(msg) { return window.confirm(msg); },
  formatDate(iso) { return new Date(iso).toLocaleDateString('ar-SA', { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' }); },
  formatCurrency(amount) { return amount.toFixed(2) + ' د'; },
  stars(rating) { return '★'.repeat(Math.round(rating)) + '☆'.repeat(5 - Math.round(rating)); },
  statusLabel(status) {
    const labels = { bidding: 'ينتظر عروض', accepted: 'تم القبول', driver_en_route: 'السائق في الطريق', in_progress: 'في التنفيذ', completed: 'مكتملة', cancelled: 'ملغاة' };
    return labels[status] || status;
  }
};

// Make globally available
window.Auth = Auth;
window.API = API;
window.WS = WS;
window.UI = UI;
