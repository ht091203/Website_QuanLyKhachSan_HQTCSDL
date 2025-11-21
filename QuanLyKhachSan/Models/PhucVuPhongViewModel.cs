using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QuanLyKhachSan.Models
{
    public class PhucVuPhongViewModel
    {
        public int MaDP { get; set; }
        public int MaPhong { get; set; }
        public string SoPhong { get; set; }
        public string TenLoai { get; set; }

        public string TenKH { get; set; }
        public string SoDienThoai { get; set; }

        public DateTime? ThoiGianNhanPhongThucTe { get; set; }
        public DateTime? ThoiGianTraPhongDuKien { get; set; }
    }

    public class CTDichVuItemViewModel
    {
        public int MaHD { get; set; }
        public int MaPhong { get; set; }
        public int MaDV { get; set; }
        public string TenDV { get; set; }
        public int SoLuong { get; set; }
        public decimal DonGia { get; set; }
        public string TrangThai { get; set; }
    }

    public class HoaDonSimpleViewModel
    {
        public int MaHD { get; set; }
        public int MaDP { get; set; }
    }

    public class CTDichVuInputModel
    {
        public int MaDP { get; set; }
        public int MaHD { get; set; }
        public int MaPhong { get; set; }

        public int MaDV { get; set; }
        public int SoLuong { get; set; }
        public string TrangThai { get; set; }
    }

    public class PhucVuChiTietViewModel
    {
        public int MaDP { get; set; }
        public int MaPhong { get; set; }
        public int MaHD { get; set; }

        public string SoPhong { get; set; }
        public string TenLoai { get; set; }
        public string TenKH { get; set; }
        public string SoDienThoai { get; set; }

        public List<CTDichVuItemViewModel> DichVuDaDung { get; set; }
        public IEnumerable<DichVu> DanhSachDichVu { get; set; }

        public CTDichVuInputModel NewCT { get; set; }
    }
}