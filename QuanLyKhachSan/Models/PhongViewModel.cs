using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QuanLyKhachSan.Models
{
    public class PhongViewModel
    {
        // --- Thông tin Phòng ---
        public int MaPhong { get; set; }
        public string SoPhong { get; set; }
        public string ViTri { get; set; }
        public string TrangThai { get; set; }

        // --- Thông tin Loại Phòng ---
        public int MaLP { get; set; }
        public string TenLoai { get; set; }
        public int SucChua { get; set; }
        public decimal DonGia { get; set; }
        public string Anh { get; set; }
        public string MoTaPhong { get; set; }
        public string MoTaLoai { get; set; }

        // --- Thông tin phụ (tính toán hoặc hiển thị) ---
        public int SoNgayO { get; set; }
        public decimal ThanhTien => SoNgayO > 0 ? DonGia * SoNgayO : 0;
    }
}