using QuanLyKhachSan.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QuanLyKhachSan.Controllers.Admin
{
    public class PhucVuController : Controller
    {
        Model1 db = new Model1();

        // ================== INDEX: DANH SÁCH PHÒNG ĐANG Ở ==================
        // Hiển thị các phòng đang được check-in (DatPhong.TinhTrang = 'Đang ở')
        public ActionResult Index()
        {
            var list = db.Database.SqlQuery<PhucVuPhongViewModel>(
                @"
                SELECT 
                    dp.MaDP,
                    p.MaPhong,
                    p.SoPhong,
                    lp.TenLoai,
                    kh.HoTen AS TenKH,
                    kh.SoDienThoai,
                    dp.ThoiGianNhanPhongThucTe,
                    dp.ThoiGianTraPhongDuKien
                FROM DatPhong dp
                INNER JOIN CT_DatPhong ct ON dp.MaDP = ct.MaDP
                INNER JOIN Phong p ON ct.MaPhong = p.MaPhong
                INNER JOIN LoaiPhong lp ON p.MaLP = lp.MaLP
                INNER JOIN KhachHang kh ON dp.MaKH = kh.MaKH
                WHERE dp.TinhTrang = N'Đang ở'
                "
            ).ToList();

            return View(list);
        }

        // ================== CHI TIẾT PHỤC VỤ (1 PHÒNG) ==================
        [HttpGet]
        public ActionResult ChiTiet(int maDP, int maPhong)
        {
            var roomInfo = db.Database.SqlQuery<PhucVuPhongViewModel>(
                "SELECT * FROM fn_LayThongTinPhucVuPhong(@MaDP, @MaPhong)",
                new SqlParameter("@MaDP", maDP),
                new SqlParameter("@MaPhong", maPhong)
            ).FirstOrDefault();

            if (roomInfo == null)
                return HttpNotFound();

            var hoaDon = db.Database.SqlQuery<HoaDonSimpleViewModel>(
                "SELECT MaHD, MaDP FROM fn_LayHoaDonTheoMaDP(@MaDP)",
                new SqlParameter("@MaDP", maDP)
            ).FirstOrDefault();

            if (hoaDon == null)
            {
                db.Database.ExecuteSqlCommand(
                    "EXEC sp_TaoHoaDon @MaDP, @PTTT, @TrangThai",
                    new SqlParameter("@MaDP", maDP),
                    new SqlParameter("@PTTT", "Tiền mặt"),
                    new SqlParameter("@TrangThai", "Đang ở")
                );

                hoaDon = db.Database.SqlQuery<HoaDonSimpleViewModel>(
                    "SELECT MaHD, MaDP FROM fn_LayHoaDonTheoMaDP(@MaDP)",
                    new SqlParameter("@MaDP", maDP)
                ).FirstOrDefault();
            }

            if (hoaDon == null)
                return Content("Không tìm được hóa đơn cho đặt phòng này.");

            int maHD = hoaDon.MaHD;

            var dsCT = db.Database.SqlQuery<CTDichVuItemViewModel>(
                "SELECT * FROM fn_LayCT_DichVuTheoHoaDonPhong(@MaHD, @MaPhong)",
                new SqlParameter("@MaHD", maHD),
                new SqlParameter("@MaPhong", maPhong)
            ).ToList();

            var dsDichVu = db.DichVus.ToList();

            var model = new PhucVuChiTietViewModel
            {
                MaDP = maDP,
                MaPhong = maPhong,
                MaHD = maHD,
                SoPhong = roomInfo.SoPhong,
                TenLoai = roomInfo.TenLoai,
                TenKH = roomInfo.TenKH,
                SoDienThoai = roomInfo.SoDienThoai,
                DichVuDaDung = dsCT,
                DanhSachDichVu = dsDichVu,
                NewCT = new CTDichVuInputModel
                {
                    MaDP = maDP,
                    MaHD = maHD,
                    MaPhong = maPhong,
                    TrangThai = "Hoàn tất"
                }
            };

            return View(model);
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ThemCTDichVu(CTDichVuInputModel model)
        {
            if (model.SoLuong <= 0)
            {
                ModelState.AddModelError("SoLuong", "Số lượng phải > 0");
            }

            if (!ModelState.IsValid)
            {
                return RedirectToAction("ChiTiet", new { maDP = model.MaDP, maPhong = model.MaPhong });
            }

            var hoaDon = db.Database.SqlQuery<HoaDonSimpleViewModel>(
                "SELECT MaHD, MaDP FROM fn_LayHoaDonTheoMaDP(@MaDP)",
                new SqlParameter("@MaDP", model.MaDP)
            ).FirstOrDefault();

            if (hoaDon == null)
            {
                TempData["ErrorMessage"] = "Không tìm được hóa đơn cho đặt phòng này. Vui lòng kiểm tra lại trạng thái Check-in.";
                return RedirectToAction("Index");
            }

            int maHD = hoaDon.MaHD;

            var donGia = db.DichVus
                .Where(d => d.MaDV == model.MaDV)
                .Select(d => d.DonGia)
                .FirstOrDefault();

            if (donGia <= 0)
            {
                TempData["ErrorMessage"] = "Không lấy được đơn giá dịch vụ. Vui lòng kiểm tra lại dịch vụ.";
                return RedirectToAction("ChiTiet", new { maDP = model.MaDP, maPhong = model.MaPhong });
            }

            db.Database.ExecuteSqlCommand(
                "EXEC sp_ThemCT_DichVu @MaHD, @MaPhong, @MaDV, @SoLuong, @DonGia, @TrangThai",
                new SqlParameter("@MaHD", maHD),
                new SqlParameter("@MaPhong", model.MaPhong),
                new SqlParameter("@MaDV", model.MaDV),
                new SqlParameter("@SoLuong", model.SoLuong),
                new SqlParameter("@DonGia", donGia),
                new SqlParameter("@TrangThai", (object)model.TrangThai ?? "Hoàn tất")
            );

            TempData["SuccessMessage"] = "Thêm dịch vụ thành công.";

            return RedirectToAction("ChiTiet", new { maDP = model.MaDP, maPhong = model.MaPhong });
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult XoaCTDichVu(int maHD, int maPhong, int maDV, int maDP)
        {
            db.Database.ExecuteSqlCommand(
                "EXEC sp_XoaCT_DichVu @MaHD, @MaPhong, @MaDV",
                new SqlParameter("@MaHD", maHD),
                new SqlParameter("@MaPhong", maPhong),
                new SqlParameter("@MaDV", maDV)
            );

            return RedirectToAction("ChiTiet", new { maDP = maDP, maPhong = maPhong });
        }
    }
}