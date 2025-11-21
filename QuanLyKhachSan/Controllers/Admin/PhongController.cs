using QuanLyKhachSan.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Mvc;

namespace QuanLyKhachSan.Controllers.Admin
{
    public class PhongController : Controller
    {
        Model1 db = new Model1();

        public ActionResult Index()
        {
            var phongList = db.Database.SqlQuery<PhongViewModel>("SELECT * FROM dbo.fn_LayTatCaPhong()").ToList();
            return View(phongList);
        }

        public ActionResult ThemPhong()
        {
            var loaiPhongList = db.Database.SqlQuery<LoaiPhong>("SELECT * FROM LoaiPhong").ToList();

            ViewBag.LoaiPhongList = new SelectList(loaiPhongList, "MaLP", "TenLoai");

            return View();
        }

        [HttpPost]
        public ActionResult ThemPhong(PhongViewModel model)
        {
            if (ModelState.IsValid)
            {
                db.Database.ExecuteSqlCommand(@"
                    INSERT INTO Phong (SoPhong, ViTri, MoTa, MaLP, TrangThai)
                    VALUES (@SoPhong, @ViTri, @MoTa, @MaLP, @TrangThai)",
                    new SqlParameter("@SoPhong", model.SoPhong),
                    new SqlParameter("@ViTri", model.ViTri ?? (object)DBNull.Value),
                    new SqlParameter("@MoTa", model.MoTaPhong ?? (object)DBNull.Value),
                    new SqlParameter("@MaLP", model.MaLP),
                    new SqlParameter("@TrangThai", model.TrangThai ?? (object)DBNull.Value)
                );

                return RedirectToAction("Index");
            }

            var loaiPhongList = db.Database.SqlQuery<LoaiPhong>("SELECT * FROM LoaiPhong").ToList();
            ViewBag.LoaiPhongList = new SelectList(loaiPhongList, "MaLP", "TenLoai", model.MaLP);

            return View(model);
        }

        public ActionResult ChinhSuaPhong(int id)
        {
            var phong = db.Database.SqlQuery<PhongViewModel>(
                "SELECT * FROM dbo.fn_LayTatCaPhong() WHERE MaPhong = @MaPhong",
                new SqlParameter("@MaPhong", id)
            ).FirstOrDefault();

            var loaiPhongList = db.Database.SqlQuery<LoaiPhong>("SELECT * FROM LoaiPhong").ToList();
            ViewBag.LoaiPhongList = new SelectList(loaiPhongList, "MaLP", "TenLoai", phong.MaLP);

            return View(phong);
        }

        [HttpPost]
        public ActionResult XoaPhong(int id)
        {
            db.Database.ExecuteSqlCommand("EXEC sp_XoaPhong @MaPhong", new SqlParameter("@MaPhong", id));
            return RedirectToAction("Index");
        }
        public ActionResult ChiTietPhong(int id)
        {
            var phong = db.Database.SqlQuery<PhongViewModel>(
                "SELECT * FROM dbo.fn_LayPhongTheoMa(@MaPhong)",
                new System.Data.SqlClient.SqlParameter("@MaPhong", id)
            ).FirstOrDefault();

            if (phong == null)
                return HttpNotFound();

            return View(phong);
        }
    }
}
