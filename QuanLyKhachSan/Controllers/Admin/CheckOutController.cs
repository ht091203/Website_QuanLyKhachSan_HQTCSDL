using QuanLyKhachSan.Models;
using QuanLyKhachSan.Services.VNPay;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QuanLyKhachSan.Controllers.Admin
{
    public class CheckOutController : Controller
    {
        Model1 db = new Model1();
        private readonly IVnPayService _vnPayService;

        public CheckOutController()
        {
            _vnPayService = new VnPayService();
        }

        public ActionResult Index()
        {
            var list = db.Database.SqlQuery<DatPhongViewModel>(
                @"SELECT * FROM fn_XemTatCaDatPhong() WHERE TinhTrang = N'Đang ở'"
            ).ToList();

            return View(list);
        }

        [HttpGet]
        public ActionResult ChiTiet(int maDP)
        {
            var header = db.Database.SqlQuery<CheckOutHeaderViewModel>(
                @"
                SELECT 
                    dp.MaDP,
                    kh.HoTen AS TenKH,
                    kh.SoDienThoai
                FROM DatPhong dp
                INNER JOIN KhachHang kh ON dp.MaKH = kh.MaKH
                WHERE dp.MaDP = @MaDP
                ",
                new SqlParameter("@MaDP", maDP)
            ).FirstOrDefault();

            if (header == null)
                return HttpNotFound("Không tìm thấy đặt phòng.");

            var chiTietPhong = db.Database.SqlQuery<ChiTietPhongItem>(
                @"
                SELECT 
                    p.SoPhong,
                    lp.TenLoai AS LoaiPhong,
                    ct.SoNgayO,
                    ct.DonGia,
                    ct.ThanhTien
                FROM CT_DatPhong ct
                INNER JOIN Phong p ON ct.MaPhong = p.MaPhong
                INNER JOIN LoaiPhong lp ON p.MaLP = lp.MaLP
                WHERE ct.MaDP = @MaDP
                ",
                new SqlParameter("@MaDP", maDP)
            ).ToList();

            var chiTietDichVu = db.Database.SqlQuery<ChiTietDichVuItem>(
                @"
                SELECT 
                    dv.TenDV,
                    ctdv.SoLuong,
                    ctdv.DonGia,
                    (ctdv.SoLuong * ctdv.DonGia) AS ThanhTien
                FROM CT_DichVu ctdv
                INNER JOIN DichVu dv ON ctdv.MaDV = dv.MaDV
                INNER JOIN HoaDon hd ON ctdv.MaHD = hd.MaHD
                WHERE hd.MaDP = @MaDP
                ",
                new SqlParameter("@MaDP", maDP)
            ).ToList();

            decimal tongPhong = chiTietPhong.Sum(x => x.ThanhTien);
            decimal tongDV = chiTietDichVu.Sum(x => x.ThanhTien);

            decimal tongCoc = db.Database.SqlQuery<decimal?>(
                "SELECT ISNULL(SUM(SoTienCoc), 0) FROM PhieuCoc WHERE MaDP = @MaDP",
                new SqlParameter("@MaDP", maDP)
            ).FirstOrDefault() ?? 0;

            decimal tongHoaDon = tongPhong + tongDV;
            decimal conPhaiTra = tongHoaDon - tongCoc;
            if (conPhaiTra < 0) conPhaiTra = 0;

            var model = new CheckOutChiTietViewModel
            {
                MaDP = maDP,
                TenKH = header.TenKH,
                SoDienThoai = header.SoDienThoai,
                ChiTietPhong = chiTietPhong,
                ChiTietDichVu = chiTietDichVu,
                TongTienPhong = tongPhong,
                TongTienDichVu = tongDV,
                TongCoc = tongCoc,
                TongHoaDon = tongHoaDon,
                ConPhaiTra = conPhaiTra,
                PTTT = "Tiền mặt"
            };

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult XacNhan(int maDP, string PTTT)
        {
            if (string.IsNullOrEmpty(PTTT))
                PTTT = "Tiền mặt";

            decimal tongPhong = db.Database.SqlQuery<decimal>(
                @"SELECT ISNULL(SUM(ThanhTien), 0) 
          FROM CT_DatPhong 
          WHERE MaDP = @p0",
                maDP
            ).FirstOrDefault();

            if (tongPhong == 0)
            {
                tongPhong = db.Database.SqlQuery<decimal>(
                    @"SELECT ISNULL(TongTienDuKien, 0)
              FROM DatPhong
              WHERE MaDP = @p0",
                    maDP
                ).FirstOrDefault();
            }

            decimal tongDV = db.Database.SqlQuery<decimal>(
                @"
        SELECT ISNULL(SUM(ctdv.SoLuong * ctdv.DonGia), 0)
        FROM CT_DichVu ctdv
        INNER JOIN HoaDon hd ON ctdv.MaHD = hd.MaHD
        WHERE hd.MaDP = @p0
        ",
                maDP
            ).FirstOrDefault();

            decimal tongCoc = db.Database.SqlQuery<decimal>(
                @"SELECT ISNULL(SUM(SoTienCoc), 0)
          FROM PhieuCoc
          WHERE MaDP = @p0",
                maDP
            ).FirstOrDefault();

            decimal tongHoaDon = tongPhong + tongDV;
            decimal soTienConLai = tongHoaDon - tongCoc;
            if (soTienConLai < 0) soTienConLai = 0;

            if (PTTT == "Chuyển khoản")
            {
                if (soTienConLai <= 0)
                {
                    TempData["ErrorMessage"] = "Không còn số tiền nào để thanh toán bằng VNPay.";
                    return RedirectToAction("ChiTiet", new { maDP });
                }

                var paymentInfo = new PaymentInformationModel
                {
                    OrderId = maDP.ToString(),                      
                    Amount = Math.Round((double)soTienConLai, 0),    
                    OrderDescription = $"Thanh toán hóa đơn đặt phòng #{maDP}",
                    Name = $"Thanh toán hóa đơn #{maDP}",
                    OrderType = "ThanhToanHoaDon",
                    ReturnUrl = Url.Action(
                        "PaymentCallbackVnpay_Admin",
                        "ThanhToan",
                        null,
                        Request.Url.Scheme
                    )
                };

                string paymentUrl = _vnPayService.CreatePaymentUrl(paymentInfo, System.Web.HttpContext.Current);

                System.Diagnostics.Debug.WriteLine("[VNPay-Admin] URL = " + paymentUrl);

                return Redirect(paymentUrl);
            }

            db.Database.ExecuteSqlCommand(
                "EXEC sp_XacNhanCheckOut @MaDP, @PTTT",
                new SqlParameter("@MaDP", maDP),
                new SqlParameter("@PTTT", PTTT)
            );

            var maHD = db.Database.SqlQuery<int?>(
                @"SELECT TOP 1 MaHD 
          FROM HoaDon 
          WHERE MaDP = @MaDP 
          ORDER BY MaHD DESC",
                new SqlParameter("@MaDP", maDP)
            ).FirstOrDefault();

            if (maHD.HasValue)
            {
                return RedirectToAction("ChiTietHoaDon", "HoaDon", new { id = maHD.Value });
            }

            return RedirectToAction("Index");
        }
    }
}