using QuanLyKhachSan.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QuanLyKhachSan.Controllers.Admin
{
    public class HoaDonController : Controller
    {
        Model1 db = new Model1();
        public ActionResult Index()
        {
            var hoaDons = db.Database.SqlQuery<HoaDonViewModel>(
                "SELECT * FROM fn_LayTatCaHoaDon()"
            ).ToList();

            return View(hoaDons);
        }
        public ActionResult ChiTietHoaDon(int id)
        {
            var model = new ChiTietHoaDonViewModel();

            var conn = db.Database.Connection as SqlConnection;
            if (conn == null)
            {
                ViewBag.Error = "Không thể lấy kết nối đến CSDL.";
                return View("Error");
            }

            try
            {
                if (conn.State == ConnectionState.Closed)
                    conn.Open();

                var cmd = new SqlCommand("sp_LayHoaDonTheoMaHD", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@MaHD", id);

                var reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    model.MaHD = reader.GetInt32(reader.GetOrdinal("MaHD"));
                    model.MaDP = reader.GetInt32(reader.GetOrdinal("MaDP"));
                    model.NgayLap = reader.GetDateTime(reader.GetOrdinal("NgayLap"));
                    model.PTTT = reader["PTTT"].ToString();
                    model.TrangThai = reader["TrangThai"].ToString();
                    model.TenKhachHang = reader["TenKhachHang"].ToString();
                    model.SoDienThoai = reader["SoDienThoai"].ToString();
                    model.ThoiGianNhanPhongThucTe = reader["ThoiGianNhanPhongThucTe"] as DateTime?;
                    model.ThoiGianTraPhongThucTe = reader["ThoiGianTraPhongThucTe"] as DateTime?;
                    model.TongTienPhong = (decimal)reader["TongTienPhong"];
                    model.TongTienDichVu = (decimal)reader["TongTienDichVu"];
                    model.TongTienHoaDon = (decimal)reader["TongTienHoaDon"];
                }

                // 2️⃣ Chi tiết phòng
                model.ChiTietPhong = new List<ChiTietPhongItem>();
                if (reader.NextResult())
                {
                    while (reader.Read())
                    {
                        model.ChiTietPhong.Add(new ChiTietPhongItem
                        {
                            SoPhong = reader["SoPhong"].ToString(),
                            LoaiPhong = reader["LoaiPhong"].ToString(),
                            SoNgayO = Convert.ToInt32(reader["SoNgayO"]),
                            DonGia = (decimal)reader["DonGia"],
                            ThanhTien = (decimal)reader["ThanhTien"]
                        });
                    }
                }

                // 3️⃣ Chi tiết dịch vụ
                model.ChiTietDichVu = new List<ChiTietDichVuItem>();
                if (reader.NextResult())
                {
                    while (reader.Read())
                    {
                        model.ChiTietDichVu.Add(new ChiTietDichVuItem
                        {
                            TenDV = reader["TenDV"].ToString(),
                            SoLuong = Convert.ToInt32(reader["SoLuong"]),
                            DonGia = (decimal)reader["DonGia"],
                            ThanhTien = (decimal)reader["ThanhTien"]
                        });
                    }
                }

                reader.Close();
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Lỗi khi lấy chi tiết hóa đơn: " + ex.Message;
                return View("Error");
            }

            return View(model);
        }
    }
}