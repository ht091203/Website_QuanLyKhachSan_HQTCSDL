using QuanLyKhachSan.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Mvc;

namespace QuanLyKhachSan.Controllers.Admin
{
    public class DichVuController : Controller
    {
        Model1 db = new Model1();
        public ActionResult Index()
        {
            var dichVuList = db.Database.SqlQuery<DichVuViewModel>(
                "SELECT * FROM fn_LayTatCaDichVu()"
            ).ToList();

            return View(dichVuList);
        }

        [HttpGet]
        public ActionResult ThemDichVu()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ThemDichVu(DichVu model)
        {
            if (ModelState.IsValid)
            {
                db.Database.ExecuteSqlCommand(
                    "EXEC sp_ThemDichVu @TenDV, @DonGia, @MoTa",
                    new SqlParameter("@TenDV", model.TenDV),
                    new SqlParameter("@DonGia", model.DonGia),
                    new SqlParameter("@MoTa", (object)model.MoTa ?? DBNull.Value)
                );
                return RedirectToAction("Index");
            }
            return View(model);
        }

        [HttpGet]
        public ActionResult ChinhSuaDichVu(int id)
        {
            var dichVu = db.DichVus.Find(id);
            if (dichVu == null)
                return HttpNotFound();

            return View(dichVu);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ChinhSuaDichVu(DichVu model)
        {
            if (ModelState.IsValid)
            {
                db.Database.ExecuteSqlCommand(
                    "EXEC sp_SuaDichVu @MaDV, @TenDV, @DonGia, @MoTa",
                    new SqlParameter("@MaDV", model.MaDV),
                    new SqlParameter("@TenDV", model.TenDV),
                    new SqlParameter("@DonGia", model.DonGia),
                    new SqlParameter("@MoTa", (object)model.MoTa ?? DBNull.Value)
                );
                return RedirectToAction("Index");
            }
            return View(model);
        }
        public ActionResult XoaDichVu(int id)
        {
            db.Database.ExecuteSqlCommand(
                "EXEC sp_XoaDichVu @MaDV",
                new SqlParameter("@MaDV", id)
            );
            return RedirectToAction("Index");
        }

        public ActionResult ChiTietDichVu(int id)
        {
            var chiTiet = db.Database.SqlQuery<DichVuViewModel>(
                "SELECT * FROM fn_LayDichVuTheoMa(@MaDV)",
                new SqlParameter("@MaDV", id)
            ).ToList();

            return View(chiTiet);
        }
    }
}
