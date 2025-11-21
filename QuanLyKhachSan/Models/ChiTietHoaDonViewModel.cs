using System;
using System.Collections.Generic;

namespace QuanLyKhachSan.Models
{
    public class ChiTietHoaDonViewModel
    {
        public int MaHD { get; set; }
        public int MaDP { get; set; }
        public DateTime NgayLap { get; set; }
        public string PTTT { get; set; }
        public string TrangThai { get; set; }
        public string TenKhachHang { get; set; }
        public string SoDienThoai { get; set; }
        public DateTime? ThoiGianNhanPhongThucTe { get; set; }
        public DateTime? ThoiGianTraPhongThucTe { get; set; }
        public decimal TongTienPhong { get; set; }
        public decimal TongTienDichVu { get; set; }
        public decimal TongTienHoaDon { get; set; }

        public List<ChiTietPhongItem> ChiTietPhong { get; set; }
        public List<ChiTietDichVuItem> ChiTietDichVu { get; set; }
    }

    public class ChiTietPhongItem
    {
        public string SoPhong { get; set; }
        public string LoaiPhong { get; set; }
        public int SoNgayO { get; set; }
        public decimal DonGia { get; set; }
        public decimal ThanhTien { get; set; }
    }

    public class ChiTietDichVuItem
    {
        public string TenDV { get; set; }
        public int SoLuong { get; set; }
        public decimal DonGia { get; set; }
        public decimal ThanhTien { get; set; }
    }
}
