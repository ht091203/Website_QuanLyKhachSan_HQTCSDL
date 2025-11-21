using QuanLyKhachSan.Models;
using QuanLyKhachSan.Services.VNPay;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QuanLyKhachSan.Controllers
{
    public class DatPhongOController : Controller
    {
        Model1 db = new Model1();
        private readonly IVnPayService _vnPayService;

        // Khởi tạo thủ công vì .NET Framework không có DI builder
        public DatPhongOController()
        {
            _vnPayService = new VnPayService();
        }

        public ActionResult ChonPhong(int MaLP = 0, int MaPhong = 0, DateTime? TuNgay = null, DateTime? DenNgay = null)
        {
            ViewBag.TuNgay = TuNgay;
            ViewBag.DenNgay = DenNgay;

            if (!TuNgay.HasValue || !DenNgay.HasValue || TuNgay >= DenNgay)
            {
                ViewBag.Error = "Vui lòng chọn ngày nhận nhỏ hơn ngày trả!";
            }
            else
            {
                var phongTrong = db.Database.SqlQuery<PhongViewModel>(
                    "SELECT * FROM dbo.fn_TimCacPhongTrongTheoMaLoai(@MaLP, @TuNgay, @DenNgay)",
                    new SqlParameter("@MaLP", MaLP),
                    new SqlParameter("@TuNgay", TuNgay.Value),
                    new SqlParameter("@DenNgay", DenNgay.Value)
                ).ToList();

                ViewBag.PhongTrong = phongTrong;
            }

            var loaiPhong = db.Database.SqlQuery<LoaiPhongViewModel>(
                "SELECT * FROM dbo.fn_LayThongTinLoaiPhong(@MaLP)",
                new SqlParameter("@MaLP", MaLP)
            ).FirstOrDefault();

            if (loaiPhong == null)
                return HttpNotFound();

            return View(loaiPhong);
        }

        public ActionResult ThongTinDatPhong(int maPhong, DateTime tuNgay, DateTime denNgay)
        {
            var phong = db.Database.SqlQuery<PhongViewModel>(
                @"SELECT p.MaPhong, p.SoPhong, lp.TenLoai, lp.DonGia
                  FROM Phong p
                  INNER JOIN LoaiPhong lp ON p.MaLP = lp.MaLP
                  WHERE p.MaPhong = @p0", maPhong
            ).FirstOrDefault();

            if (phong == null)
            {
                ViewBag.Error = "Phòng không tồn tại!";
                return RedirectToAction("Index", "XemPhong");
            }

            var model = new DatPhongViewModel
            {
                MaKH = Convert.ToInt32(Session["MaKH"]),
                MaPhong = phong.MaPhong,
                SoPhong = phong.SoPhong,
                TenLoai = phong.TenLoai,
                DonGia = phong.DonGia,
                ThoiGianNhanPhong = tuNgay,
                ThoiGianTraPhongDuKien = denNgay,
                SoNgayO = (denNgay - tuNgay).Days,
                TongTienDuKien = phong.DonGia * (denNgay - tuNgay).Days,
                NgayDat = DateTime.Now
            };

            return View("ThongTinDatPhong", model);
        }
        [HttpPost]
        public ActionResult XacNhanDatPhong(DatPhongViewModel model)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.Error = "Dữ liệu không hợp lệ.";
                return View("ThongTinDatPhong", model);
            }

            try
            {
                // Thêm đặt phòng
                var maDPMoi = Convert.ToInt32(db.Database.SqlQuery<decimal>(
                    "EXEC sp_ThemDatPhong @p0,@p1,@p2,@p3,@p4,@p5,@p6",
                    model.MaKH,
                    DateTime.Now,
                    model.ThoiGianNhanPhong,
                    model.ThoiGianTraPhongDuKien,
                    "Chờ xác nhận",
                    model.TongTienDuKien,
                    "Chưa cọc"
                ).FirstOrDefault());

                // Thêm chi tiết đặt phòng
                db.Database.ExecuteSqlCommand(
                    "EXEC sp_ThemCTDatPhong @p0,@p1,@p2,@p3",
                    maDPMoi,
                    model.MaPhong,
                    model.DonGia,
                    model.SoNgayO
                );

                // Tính tiền cần thanh toán (theo % cọc)
                double soTienThanhToan = (double)(model.TongTienDuKien * model.PhanTramCoc / 100);

                // Chuẩn bị model thanh toán
                var paymentInfo = new PaymentInformationModel
                {
                    Amount = soTienThanhToan,
                    OrderType = "DatPhong",
                    OrderDescription = $"Đặt cọc {model.PhanTramCoc}% cho phòng {model.SoPhong}",
                    Name = $"Thanh toán đặt phòng #{maDPMoi}",
                    OrderId = maDPMoi.ToString() 
                };

                // Tạo URL thanh toán VNPay, dùng OrderId làm vnp_TxnRef
                string paymentUrl = _vnPayService.CreatePaymentUrl(paymentInfo, System.Web.HttpContext.Current);

                return Redirect(paymentUrl);
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Lỗi khi đặt phòng: " + ex.Message;
                return View("ThongTinDatPhong", model);
            }
        }
    }
}
