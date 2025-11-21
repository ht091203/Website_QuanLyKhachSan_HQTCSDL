using QuanLyKhachSan.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QuanLyKhachSan.Controllers.Admin
{
    public class NhanVienController : Controller
    {
        // GET: NhanVien
        private Model1 db = new Model1();

        // GET: NhanVien
        public ActionResult Index()
        {
            var nhanViens = db.Database.SqlQuery<NhanVien>("SELECT * FROM dbo.fn_LayTatCaNhanVien()").ToList();
            return View(nhanViens);
        }

        // GET: Chi tiết
        public ActionResult ChiTietNhanVien(int id)
        {
            var nv = db.Database.SqlQuery<NhanVien>("SELECT * FROM dbo.fn_LayNhanVienTheoMa(@MaNV)",
                new SqlParameter("@MaNV", id)).FirstOrDefault();
            if (nv == null) return HttpNotFound();
            return View(nv);
        }

        // GET: Thêm
        public ActionResult ThemNhanVien()
        {
            return View();
        }

        // POST: Thêm
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ThemNhanVien(NhanVien model)
        {
            if (ModelState.IsValid)
            {
                db.Database.ExecuteSqlCommand("EXEC sp_ThemNhanVien @HoTen, @NgaySinh, @GioiTinh, @SoDienThoai, @Email, @DiaChi",
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
        public ActionResult ChinhSuaNhanVien(int id)
        {
            var nv = db.Database.SqlQuery<NhanVien>("SELECT * FROM dbo.fn_LayNhanVienTheoMa(@MaNV)",
                new SqlParameter("@MaNV", id)).FirstOrDefault();
            if (nv == null) return HttpNotFound();
            return View(nv);
        }
        // POST: Chỉnh sửa
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ChinhSuaNhanVien(NhanVien model)
        {
            if (ModelState.IsValid)
            {
                db.Database.ExecuteSqlCommand("EXEC sp_ChinhSuaNhanVien @MaNV, @HoTen, @NgaySinh, @GioiTinh, @SoDienThoai, @Email, @DiaChi",
                    new SqlParameter("@MaNV", model.MaNV),
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
        public ActionResult XoaNhanVien(int id)
        {
            db.Database.ExecuteSqlCommand("EXEC sp_XoaNhanVien @MaNV",
                new SqlParameter("@MaNV", id));
            return RedirectToAction("Index");
        }
    }
}