THOI KHOA BIEU - GITHUB PAGES + GITHUB ACTIONS (KHONG CAN PROXY NGOAI)

CO CHE
- GitHub Actions chay dinh ky, goi API cong khai cua Phong Dao tao tu may chu GitHub.
- Du lieu duoc luu thanh JSON trong thu muc data/ cua repository.
- GitHub Pages chi doc JSON cung nguon, nen trinh duyet nguoi xem khong goi API truong va khong gap loi CORS.
- Khong can Cloudflare, Netlify, PowerShell, API key hay may chu proxy rieng.

QUAN TRONG
- Nen de repository o che do PUBLIC de GitHub-hosted standard runner cua Actions mien phi.
- GitHub Actions co the tre lich chay; cron 15 phut khong co nghia la du lieu chac chan cap nhat dung tung 15 phut.
- Goi API truong van co the bi truong chan, doi API, hoac tra loi khong phai JSON. Khi do workflow se bao loi va giu ban JSON tot truoc do.
- Goi nay dong bo 9 tuan: 2 tuan truoc, tuan hien tai va 2 tuan tiep theo. Chon tuan nam ngoai khoang nay se chua co snapshot.
- Neu repository public khong co hoat dong trong 60 ngay, GitHub co the tu dong tat scheduled workflow. Can vao Actions de bat lai.

CAI DAT
1. Giai nen ZIP.
2. Tai TOAN BO noi dung thu muc TKB_CDYT_GITHUB_ACTIONS len repository GitHub dang dung. Giu nguyen cau truc, dac biet la thu muc an .github/workflows.
3. Dam bao index.html nam o thu muc goc repository.
4. Vao repository > Settings > Actions > General.
5. Tim Workflow permissions, chon "Read and write permissions", Save.
6. Vao tab Actions. Neu GitHub hien nut "I understand my workflows, go ahead and enable them" thi bam enable.
7. Chon workflow "Update public timetable data" > Run workflow > Run workflow de chay thu lan dau.
8. Cho job chay xong. Mo thu muc data/ trong repository. Can thay cac file week-YYYY-MM-DD.json va status.json.
9. Bat GitHub Pages: Settings > Pages > Deploy from a branch > main > /(root) > Save.
10. Mo website GitHub Pages. Mac dinh loc lop 19D. Bam Tai thoi khoa bieu neu can.

NEU MUON UPLOAD QUA GITHUB WEB
- GitHub web upload co the kho upload thu muc an .github. Neu khong thay .github/workflows/update-schedule.yml tren repository, can tao thu muc va file nay thu cong tren GitHub: Add file > Create new file, nhap dung duong dan .github/workflows/update-schedule.yml, dan noi dung tu file cung ten trong ZIP, Commit changes.
- Tuong tu, dam bao scripts/fetch_schedule.py duoc upload dung duong dan.

KIEM TRA LOI
- Actions > Update public timetable data > mo run moi nhat > xem buoc Fetch timetable snapshots.
- Mo data/status.json de xem thoi diem dong bo va loi tung tuan.
- Neu API truong tra 404/HTML/khong phai JSON, day la loi tu API nguon; GitHub Actions khong the tu tao ra du lieu.

CAP NHAT
- Workflow chay moi 30 phut (cron phut 11 va 41 UTC).
- Trang web tu doc lai snapshot moi moi 5 phut khi tab dang mo.
- Muon dong bo ngay: vao Actions va bam Run workflow.
