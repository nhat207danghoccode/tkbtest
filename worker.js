const UPSTREAM = 'https://phongdaotao.cdytehatinh.edu.vn';
const ALLOWED_PATHS = new Set([
  '/api/attendance/general-schedules/week',
  '/api/attendance/general-schedules',
  '/api/attendance/general-schedule-classes',
  '/api/attendance/academic-weeks'
]);

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Accept, Content-Type',
    'Access-Control-Max-Age': '86400',
    'Cache-Control': 'no-store'
  };
}

export default {
  async fetch(request) {
    const incoming = new URL(request.url);
    const cors = corsHeaders();
    if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors });
    if (request.method !== 'GET') return new Response(JSON.stringify({ message: 'Chỉ hỗ trợ GET.' }), {
      status: 405, headers: { ...cors, 'Content-Type': 'application/json; charset=utf-8' }
    });
    if (!ALLOWED_PATHS.has(incoming.pathname)) return new Response(JSON.stringify({ message: 'Đường dẫn API không được cho phép.' }), {
      status: 404, headers: { ...cors, 'Content-Type': 'application/json; charset=utf-8' }
    });

    const target = new URL(UPSTREAM + incoming.pathname);
    incoming.searchParams.forEach((value, key) => target.searchParams.set(key, value));
    try {
      const upstream = await fetch(target.toString(), {
        method: 'GET',
        headers: {
          'Accept': 'application/json, text/plain, */*',
          'Referer': UPSTREAM + '/xem-lich-hoc/lich-cong-khai'
        },
        redirect: 'follow'
      });
      const body = await upstream.text();
      const contentType = upstream.headers.get('content-type') || '';
      const headers = new Headers(cors);
      headers.set('Content-Type', contentType || 'text/plain; charset=utf-8');
      headers.set('X-TKB-Upstream-Status', String(upstream.status));
      return new Response(body, { status: upstream.status, headers });
    } catch (error) {
      return new Response(JSON.stringify({ message: 'Worker không kết nối được máy chủ Phòng Đào tạo.', detail: String(error?.message || error) }), {
        status: 502, headers: { ...cors, 'Content-Type': 'application/json; charset=utf-8' }
      });
    }
  }
};
