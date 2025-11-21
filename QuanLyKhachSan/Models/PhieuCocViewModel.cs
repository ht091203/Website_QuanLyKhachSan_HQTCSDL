using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QuanLyKhachSan.Models
{
    public class PhieuCocViewModel
    {
        public int MaPC { get; set; }
        public string HoTen { get; set; }
        public string SoDienThoai { get; set; }
        public DateTime? NgayCoc { get; set; }
        public decimal SoTienCoc { get; set; }
        public string PTTT { get; set; }
        public string TrangThaiCoc { get; set; }
    }

}