using QuanLyKhachSan.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QuanLyKhachSan.Controllers.Admin
{
    public class PhieuCocController : Controller
    {
        Model1 db = new Model1();
        public ActionResult Index()
        {
            var phieuCocs = db.Database.SqlQuery<PhieuCocViewModel>(
                "SELECT * FROM fn_LayTatCaPhieuCoc()"
            ).ToList();

            return View(phieuCocs);
        }
    }
}