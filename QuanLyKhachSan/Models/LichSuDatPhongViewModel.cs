using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QuanLyKhachSan.Models
{
    public class LichSuDatPhongViewModel
    {
        public int MaDP { get; set; }
        public DateTime NgayDat { get; set; }
        public DateTime? ThoiGianNhanPhong { get; set; }
        public DateTime? ThoiGianTraPhongDuKien { get; set; }
        public string TinhTrang { get; set; }
        public decimal TongTienDuKien { get; set; }
        public string TrangThaiCoc { get; set; }

        public int? MaPhong { get; set; }
        public decimal? DonGia { get; set; }
        public int? SoNgayO { get; set; }
        public decimal? ThanhTien { get; set; }

        public int? MaPC { get; set; }
        public DateTime? NgayCoc { get; set; }
        public decimal? SoTienCoc { get; set; }
        public string PTTT { get; set; }
    }
}