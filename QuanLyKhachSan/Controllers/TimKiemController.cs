using QuanLyKhachSan.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Mvc;

namespace QuanLyKhachSan.Controllers
{
    public class TimKiemController : Controller
    {
        Model1 db = new Model1();

        [HttpGet]
        public ActionResult PhongTrong(DateTime TuNgay, DateTime DenNgay, int SoKhach = 1)
        {
            if (TuNgay >= DenNgay)
            {
                ViewBag.Error = "Ngày nhận phải nhỏ hơn ngày trả!";
                return View(new List<LoaiPhongViewModel>());
            }

            var loaiPhongs = db.Database.SqlQuery<LoaiPhongViewModel>(
                "SELECT * FROM dbo.fn_LoaiPhongConPhongTrong(@TuNgay, @DenNgay, @SoKhach)",
                new SqlParameter("@TuNgay", TuNgay),
                new SqlParameter("@DenNgay", DenNgay),
                new SqlParameter("@SoKhach", SoKhach)
            ).ToList();

            ViewBag.TuNgay = TuNgay;
            ViewBag.DenNgay = DenNgay;
            ViewBag.SoKhach = SoKhach;

            return View(loaiPhongs);
        }
    }
}
