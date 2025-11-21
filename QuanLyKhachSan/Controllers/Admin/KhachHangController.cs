using QuanLyKhachSan.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QuanLyKhachSan.Controllers.Admin
{
    public class KhachHangController : Controller
    {
        // GET: KhachHang
        private Model1 db = new Model1();
        private string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["Model1"].ConnectionString;

        // GET: KhachHang
        public ActionResult Index()
        {
            var khachHangs = db.Database.SqlQuery<KhachHang>("SELECT * FROM dbo.fn_LayTatCaKhachHang()").ToList();
            return View(khachHangs);
        }

        // GET: Chi tiết
        public ActionResult ChiTietKhachHang(int id)
        {
            var kh = db.Database.SqlQuery<KhachHang>("SELECT * FROM dbo.fn_LayKhachHangTheoMa(@MaKH)",
                new SqlParameter("@MaKH", id)).FirstOrDefault();

            if (kh == null) return HttpNotFound();
            return View(kh);
        }

        // GET: Thêm
        public ActionResult ThemKhachHang()
        {
            return View();
        }

        // POST: Thêm
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ThemKhachHang(KhachHang model)
        {
            if (ModelState.IsValid)
            {
                db.Database.ExecuteSqlCommand("EXEC sp_ThemKhachHang @HoTen, @NgaySinh, @GioiTinh, @SoDienThoai, @Email, @DiaChi",
                    new SqlParameter("@HoTen", model.HoTen ?? (object)DBNull.Value),
                    new SqlParameter("@NgaySinh", model.NgaySinh ?? (object)DBNull.Value),
                    new SqlParameter("@GioiTinh", model.GioiTinh ?? (object)DBNull.Value),
                    new SqlParameter("@SoDienThoai", model.SoDienThoai ?? (object)DBNull.Value),
                    new SqlParameter("@Email", model.Email ?? (object)DBNull.Value),
                    new SqlParameter("@DiaChi", model.DiaChi ?? (object)DBNull.Value));
                return RedirectToAction("Index");
            }
            return View(model);
        }

        // GET: Chỉnh sửa
        public ActionResult ChinhSuaKhachHang(int id)
        {
            var kh = db.Database.SqlQuery<KhachHang>("SELECT * FROM dbo.fn_LayKhachHangTheoMa(@MaKH)",
                new SqlParameter("@MaKH", id)).FirstOrDefault();
            if (kh == null) return HttpNotFound();
            return View(kh);
        }

        // POST: Chỉnh sửa
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ChinhSuaKhachHang(KhachHang model)
        {
            if (ModelState.IsValid)
            {
                db.Database.ExecuteSqlCommand("EXEC sp_ChinhSuaKhachHang @MaKH, @HoTen, @NgaySinh, @GioiTinh, @SoDienThoai, @Email, @DiaChi",
                    new SqlParameter("@MaKH", model.MaKH),
                    new SqlParameter("@HoTen", model.HoTen ?? (object)DBNull.Value),
                    new SqlParameter("@NgaySinh", model.NgaySinh ?? (object)DBNull.Value),
                    new SqlParameter("@GioiTinh", model.GioiTinh ?? (object)DBNull.Value),
                    new SqlParameter("@SoDienThoai", model.SoDienThoai ?? (object)DBNull.Value),
                    new SqlParameter("@Email", model.Email ?? (object)DBNull.Value),
                    new SqlParameter("@DiaChi", model.DiaChi ?? (object)DBNull.Value));
                return RedirectToAction("Index");
            }
            return View(model);
        }

        // GET: Xóa
        public ActionResult XoaKhachHang(int id)
        {
            db.Database.ExecuteSqlCommand("EXEC sp_XoaKhachHang @MaKH",
                new SqlParameter("@MaKH", id));
            return RedirectToAction("Index");
        }
    }
}