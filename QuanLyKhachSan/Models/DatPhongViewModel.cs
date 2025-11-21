using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QuanLyKhachSan.Models
{
    public class DatPhongViewModel
    {
        public int MaDP { get; set; }
        public int MaKH { get; set; }
        public string TenKH { get; set; }
        public DateTime NgayDat { get; set; }
        public DateTime? ThoiGianNhanPhong { get; set; }
        public DateTime? ThoiGianTraPhongDuKien { get; set; }
        public DateTime? ThoiGianNhanPhongThucTe { get; set; }
        public DateTime? ThoiGianTraPhongThucTe { get; set; }
        public string TinhTrang { get; set; }
        public decimal TongTienDuKien { get; set; }
        public string TrangThaiCoc { get; set; }

        public int MaPhong { get; set; }
        public string SoPhong { get; set; }      
        public string TenLoai { get; set; }    
        public decimal DonGia { get; set; }
        public int SoNgayO { get; set; }
        public decimal ThanhTien { get; set; }

        public int PhanTramCoc { get; set; } = 40;

        public decimal SoTienCoc
        {
            get
            {
                return TongTienDuKien * PhanTramCoc / 100;
            }
        }
    }

}