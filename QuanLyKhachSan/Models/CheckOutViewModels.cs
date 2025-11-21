using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QuanLyKhachSan.Models
{
    public class CheckOutHeaderViewModel
    {
        public int MaDP { get; set; }
        public string TenKH { get; set; }
        public string SoDienThoai { get; set; }
    }

    public class CheckOutChiTietViewModel
    {
        public int MaDP { get; set; }

        public string TenKH { get; set; }
        public string SoDienThoai { get; set; }

        public List<ChiTietPhongItem> ChiTietPhong { get; set; }
        public List<ChiTietDichVuItem> ChiTietDichVu { get; set; }

        public decimal TongTienPhong { get; set; }
        public decimal TongTienDichVu { get; set; }
        public decimal TongCoc { get; set; }
        public decimal TongHoaDon { get; set; }
        public decimal ConPhaiTra { get; set; }

        public string PTTT { get; set; } 
    }
}