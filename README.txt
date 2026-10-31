THỜI KHÓA BIỂU - BẢN GITHUB PAGES + CLOUDFLARE WORKER

GÓI NÀY GỒM
- index.html: trang lịch học để đưa lên GitHub Pages.
- worker.js: mã proxy chạy trên Cloudflare Workers.

LƯU Ý
GitHub Pages chỉ lưu và phân phối HTML tĩnh, không chạy được API proxy. Vì vậy cần triển khai worker.js một lần trên Cloudflare Workers. Bản thân trang HTML không thể tự vượt CORS.

BƯỚC 1 - TẠO WORKER
1. Đăng nhập https://dash.cloudflare.com/
2. Vào Workers & Pages.
3. Chọn Create application / Create Worker.
4. Đặt tên ví dụ: tkb-cdytht-proxy.
5. Chọn Edit code.
6. Xóa mã mẫu, mở worker.js trong gói này, sao chép toàn bộ và dán vào trình soạn thảo.
7. Nhấn Deploy.
8. Sao chép địa chỉ dạng https://tkb-cdytht-proxy.<ten-tai-khoan>.workers.dev

BƯỚC 2 - ĐƯA HTML LÊN GITHUB PAGES
1. Tạo hoặc mở repository GitHub.
2. Tải index.html trong gói này lên repository và đặt đúng tên index.html ở thư mục gốc (root).
3. Vào Settings > Pages.
4. Chọn Deploy from a branch, chọn nhánh main và thư mục /(root), rồi Save.

BƯỚC 3 - KẾT NỐI
1. Mở website GitHub Pages.
2. Mở mục “Cấu hình kết nối GitHub Pages / Proxy”.
3. Dán địa chỉ Worker đã sao chép (không thêm đường dẫn API ở cuối).
4. Nhấn “Lưu địa chỉ Proxy”.
5. Trang sẽ tự tải lịch và tự cập nhật mỗi 60 giây.

KIỂM TRA WORKER
Mở thử URL này trên trình duyệt, thay bằng địa chỉ Worker của bạn:
https://TEN-WORKER.workers.dev/api/attendance/general-schedules/week?date=2026-11-02&schoolYear=2026%20-%202027&semester=1

Nếu Worker trả HTTP 404 hoặc HTML thay vì JSON, có thể API nguồn đã đổi đường dẫn, cần kiểm tra lại API của trang trường. Worker chỉ chuyển tiếp dữ liệu; nó không thể bỏ qua đăng nhập, chống bot hoặc giới hạn truy cập của máy chủ trường.

BẢO MẬT
Worker hiện chỉ cho phép GET đến 4 đường dẫn API lịch học được liệt kê trong mã. Không có API key hoặc mật khẩu trong HTML.
