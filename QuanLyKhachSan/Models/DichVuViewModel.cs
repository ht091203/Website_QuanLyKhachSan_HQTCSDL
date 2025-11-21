using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QuanLyKhachSan.Models
{
    public class DichVuViewModel
    {
        public int MaDV { get; set; }
        public string TenDV { get; set; }
        public decimal DonGiaGoc { get; set; }
        public string MoTa { get; set; }
        public int? MaHD { get; set; }
        public int? MaPhong { get; set; }
        public int? SoLuong { get; set; }
        public decimal? DonGiaThucTe { get; set; }
        public string TrangThai { get; set; }
    }
}