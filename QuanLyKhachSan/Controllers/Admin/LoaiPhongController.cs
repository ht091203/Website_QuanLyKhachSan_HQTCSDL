using QuanLyKhachSan.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QuanLyKhachSan.Controllers.Admin
{
    public class LoaiPhongController : Controller
    {
        private Model1 db = new Model1();
        public ActionResult Index()
        {
            var loaiPhongs = db.Database.SqlQuery<LoaiPhong>(
                "SELECT * FROM dbo.fn_LayTatCaLoaiPhong()"
            ).ToList();

            return View(loaiPhongs);
        }
        public ActionResult ThemLoaiPhong()
        {
            return View();
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ThemLoaiPhong(LoaiPhong lp)
        {
            if (ModelState.IsValid)
            {
                db.Database.ExecuteSqlCommand(
                    "EXEC sp_ThemLoaiPhong @TenLoai, @MoTa, @DonGia",
                    new SqlParameter("@TenLoai", lp.TenLoai),
                    new SqlParameter("@MoTa", (object)lp.MoTa ?? DBNull.Value),
                    new SqlParameter("@DonGia", lp.DonGia)
                );

                return RedirectToAction("Index");
            }
            return View(lp);
        }
        public ActionResult ChinhSuaLoaiPhong(int id)
        {
            var lp = db.LoaiPhongs.Find(id);
            if (lp == null)
            {
                return HttpNotFound();
            }
            return View(lp);
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ChinhSuaLoaiPhong(LoaiPhong lp)
        {
            if (ModelState.IsValid)
            {
                db.Database.ExecuteSqlCommand(
                    "EXEC sp_ChinhSuaLoaiPhong @MaLP, @TenLoai, @MoTa, @DonGia",
                    new SqlParameter("@MaLP", lp.MaLP),
                    new SqlParameter("@TenLoai", lp.TenLoai),
                    new SqlParameter("@MoTa", (object)lp.MoTa ?? DBNull.Value),
                    new SqlParameter("@DonGia", lp.DonGia)
                );

                return RedirectToAction("Index");
            }
            return View(lp);
        }
        public ActionResult XoaLoaiPhong(int id)
        {
            db.Database.ExecuteSqlCommand(
                "EXEC sp_XoaLoaiPhong @MaLP",
                new SqlParameter("@MaLP", id)
            );

            return RedirectToAction("Index");
        }
    }
}