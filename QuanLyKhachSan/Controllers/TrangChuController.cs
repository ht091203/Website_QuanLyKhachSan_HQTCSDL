using QuanLyKhachSan.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QuanLyKhachSan.Controllers
{
    public class TrangChuController : Controller
    {
        Model1 db = new Model1();
        public ActionResult Index()
        {
            return View();
        }
        public ActionResult GioiThieu()
        {
            return View();
        }
        public ActionResult LienHe()
        {
            return View();
        }
        public ActionResult DangKy()
        {
            return View();
        }

        [HttpPost]
        public ActionResult DangKy(DangKyViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            int maTKMoi = 0;
            string error = null;

            try
            {
                var maTKParam = new System.Data.SqlClient.SqlParameter
                {
                    ParameterName = "@MaTKMoi",
                    SqlDbType = System.Data.SqlDbType.Int,
                    Direction = System.Data.ParameterDirection.Output
                };

                var errorParam = new System.Data.SqlClient.SqlParameter
                {
                    ParameterName = "@ErrorMessage",
                    SqlDbType = System.Data.SqlDbType.NVarChar,
                    Size = 200,
                    Direction = System.Data.ParameterDirection.Output
                };

                db.Database.ExecuteSqlCommand(
                    "EXEC sp_DangKyTaiKhoanSQL @HoTen, @NgaySinh, @GioiTinh, @SoDienThoai, @Email, @DiaChi, @TenDN, @MatKhau, @LoaiTaiKhoan, @MaTKMoi OUT, @ErrorMessage OUT",
                    new System.Data.SqlClient.SqlParameter("@HoTen", model.HoTen),
                    new System.Data.SqlClient.SqlParameter("@NgaySinh", model.NgaySinh),
                    new System.Data.SqlClient.SqlParameter("@GioiTinh", model.GioiTinh),
                    new System.Data.SqlClient.SqlParameter("@SoDienThoai", model.SoDienThoai),
                    new System.Data.SqlClient.SqlParameter("@Email", model.Email),
                    new System.Data.SqlClient.SqlParameter("@DiaChi", model.DiaChi),
                    new System.Data.SqlClient.SqlParameter("@TenDN", model.TenDN),
                    new System.Data.SqlClient.SqlParameter("@MatKhau", model.MatKhau),
                    new System.Data.SqlClient.SqlParameter("@LoaiTaiKhoan", "KH"),
                    maTKParam,
                    errorParam
                );

                maTKMoi = (maTKParam.Value != DBNull.Value) ? Convert.ToInt32(maTKParam.Value) : 0;
                error = errorParam.Value as string;

                if (!string.IsNullOrEmpty(error))
                {
                    ViewBag.Error = error;
                    return View(model);
                }

                TempData["Success"] = "Đăng ký thành công!";
                return RedirectToAction("DangNhap", "TrangChu");
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Lỗi: " + ex.Message;
                return View(model);
            }
        }

        // GET: DangNhap
        public ActionResult DangNhap()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult DangNhap(DangNhapViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var tk = db.TaiKhoans.FirstOrDefault(t => t.TenDN == model.TenDN && t.MatKhau == model.MatKhau);
            if (tk == null)
            {
                ModelState.AddModelError("", "Tên đăng nhập hoặc mật khẩu không đúng.");
                return View(model);
            }

            Session["TenDN"] = tk.TenDN;
            Session["LoaiTaiKhoan"] = tk.LoaiTaiKhoan;
            Session["MaKH"] = tk.MaKH;
            Session["MaNV"] = tk.MaNV;

            if (tk.LoaiTaiKhoan == "KH")
            {
                return RedirectToAction("Index", "TrangChu");
            }
            else if (tk.LoaiTaiKhoan == "NV")
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                return RedirectToAction("Index", "Home");
            }
        }
        public ActionResult DangXuat()
        {
            Session.Clear();
            return RedirectToAction("Index", "TrangChu");
        }
        public ActionResult LichSuDatPhong()
        {
            try
            {
                int maKH = Convert.ToInt32(Session["MaKH"]);

                var lichSu = db.Database.SqlQuery<LichSuDatPhongViewModel>(
                    "EXEC sp_LayLichSuDatPhong @p0", maKH).ToList();

                return View(lichSu);
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Lỗi lấy lịch sử đặt phòng: " + ex.Message;
                return View("Error");
            }
        }
    }
}