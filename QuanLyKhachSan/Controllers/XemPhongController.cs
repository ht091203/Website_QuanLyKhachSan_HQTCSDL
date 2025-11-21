using QuanLyKhachSan.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QuanLyKhachSan.Controllers
{
    public class XemPhongController : Controller
    {
        Model1 db = new Model1();
        public ActionResult Index(int page = 1, int pageSize = 12)
        {
            var danhSachPhong = db.Database.SqlQuery<LoaiPhongViewModel>(
                "SELECT * FROM dbo.fn_LayTatCaLoaiPhong()"
            ).ToList();

            int totalItems = danhSachPhong.Count();

            var items = danhSachPhong
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToList();

            ViewBag.Page = page;
            ViewBag.TotalPages = (int)Math.Ceiling((double)totalItems / pageSize);

            return View(items);
        }

        public ActionResult XemChiTiet(int id)
        {
            var phong = db.Database.SqlQuery<LoaiPhongViewModel>(
                "SELECT * FROM dbo.fn_LayThongTinLoaiPhong({0})", id
            ).FirstOrDefault();

            if (phong == null)
            {
                return HttpNotFound();
            }

            return View(phong);
        }
    }
}