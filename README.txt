THỜI KHÓA BIỂU - CAO ĐẲNG Y TẾ HÀ TĨNH

1. GitHub Pages
- Giải nén gói ZIP.
- Đưa TKB_CDYT.html vào repository GitHub Pages và đổi tên thành index.html.
- Commit/push để GitHub Pages xuất bản.
- Mở trang. Bản HTML sẽ thử gọi API của trường trực tiếp, không cần proxy nếu máy chủ cho phép CORS.

2. Nếu GitHub Pages báo lỗi CORS
- Tạo một Cloudflare Worker mới.
- Dán nội dung trong worker.js.txt vào trình soạn thảo Worker rồi Deploy.
- Sao chép địa chỉ Worker dạng https://ten-worker.ten-tai-khoan.workers.dev.
- Mở trang GitHub Pages, mở mục Cài đặt kết nối nâng cao, dán địa chỉ Worker và nhấn Lưu địa chỉ kết nối.

3. Tính năng
- Chọn một ngày để xem cả tuần chứa ngày đó.
- Mặc định lọc lớp 19D; xóa nội dung bộ lọc để xem tất cả lớp.
- Tìm theo lớp, môn học hoặc giảng viên.
- Tự làm mới mỗi 60 giây; có thể tắt.
- Xuất lịch đang lọc thành CSV.

Lưu ý: API thật đã được lấy từ mã JavaScript của trang lịch công khai. Tuy nhiên, môi trường tạo file không truy cập được máy chủ của trường để kiểm tra CORS hoặc xác nhận dữ liệu trực tiếp. Vì vậy cần mở trang trên trình duyệt để kiểm chứng kết nối. Nếu trình duyệt chặn CORS, dùng Worker kèm theo. Không có dữ liệu lịch mẫu giả được chèn vào trang.
