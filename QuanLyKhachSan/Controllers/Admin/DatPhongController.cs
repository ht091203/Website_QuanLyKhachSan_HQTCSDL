using QuanLyKhachSan.Models;
using System;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Mvc;

namespace QuanLyKhachSan.Controllers.Admin
{
    public class DatPhongController : Controller
    {
        Model1 db = new Model1();

        public ActionResult Index()
        {
            var list = db.Database.SqlQuery<DatPhongViewModel>("SELECT * FROM fn_XemTatCaDatPhong()").ToList();

            var khachHangs = db.Database.SqlQuery<KhachHang>(
                "SELECT * FROM fn_LayTatCaKhachHang()"
            ).ToList();

            ViewBag.KhachHangs = new SelectList(khachHangs, "MaKH", "HoTen");
            return View(list);
        }

        [HttpGet]
        public ActionResult ChinhSuaDatPhong(int id)
        {
            var parameter = new SqlParameter("@MaDP", id);
            var details = db.Database.SqlQuery<DatPhongViewModel>(
                "SELECT * FROM fn_XemDatPhongTheoMaDP(@MaDP)", parameter
            ).FirstOrDefault();

            if (details == null)
            {
                return HttpNotFound();
            }

            var khachHangs = db.Database.SqlQuery<KhachHang>(
                "SELECT * FROM fn_LayTatCaKhachHang()"
            ).ToList();
            ViewBag.KhachHangs = khachHangs;

            var phongs = db.Database.SqlQuery<PhongViewModel>(
                "SELECT * FROM fn_LayTatCaPhong()"
            ).ToList();
            ViewBag.Phong = phongs;

            return View(details);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ChinhSuaDatPhong(DatPhongViewModel datPhong)
        {
            try
            {
                DateTime FixDate(DateTime date) =>
                    (date < new DateTime(1753, 1, 1)) ? DateTime.Now : date;

                var nhanPhong = FixDate(datPhong.ThoiGianNhanPhong ?? DateTime.Now);
                var traPhong = FixDate(datPhong.ThoiGianTraPhongDuKien ?? DateTime.Now.AddDays(1));

                var parameters = new[]
                {
                    new SqlParameter("@MaDP", datPhong.MaDP),
                    new SqlParameter("@ThoiGianNhanPhong", (object)nhanPhong ?? DBNull.Value),
                    new SqlParameter("@ThoiGianTraPhongDuKien", (object)traPhong ?? DBNull.Value),
                    new SqlParameter("@TinhTrang", (object)datPhong.TinhTrang ?? DBNull.Value)
                };

                int rows = db.Database.ExecuteSqlCommand(
                    "EXEC sp_ChinhSuaDatPhong @MaDP, @ThoiGianNhanPhong, @ThoiGianTraPhongDuKien, @TinhTrang",
                    parameters
                );

                TempData["SuccessMessage"] = rows != 0
                    ? "Cập nhật đặt phòng thành công!"
                    : "Không có bản ghi nào được cập nhật.";
            }
            catch (SqlException ex)
            {
                TempData["ErrorMessage"] = "Lỗi SQL: " + ex.Message;
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Lỗi khi cập nhật: " + ex.Message;
            }

            return RedirectToAction("Index");
        }

        public ActionResult XoaDatPhong(int id)
        {
            var parameter = new SqlParameter("@MaDP", id);
            db.Database.ExecuteSqlCommand("EXEC sp_XoaDatPhong @MaDP", parameter);
            return RedirectToAction("Index");
        }

        public ActionResult ChiTietDatPhong(int id)
        {
            var parameter = new SqlParameter("@MaDP", id);
            var details = db.Database.SqlQuery<DatPhongViewModel>(
                "SELECT * FROM fn_XemDatPhongTheoMaDP(@MaDP)", parameter
            ).FirstOrDefault();

            if (details == null)
            {
                return HttpNotFound();
            }

            return View(details);
        }

        [HttpPost]
        public ActionResult XacNhanCheckIn(int maDP)
        {
            try
            {
                db.Database.ExecuteSqlCommand(
                    "EXEC sp_XacNhanCheckIn @MaDP",
                    new SqlParameter("@MaDP", maDP)
                );
                TempData["SuccessMessage"] = "Khách hàng đã Check-in thành công!";
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Lỗi khi Check-in: " + ex.Message;
            }
            return RedirectToAction("Index");
        }
    }
}
