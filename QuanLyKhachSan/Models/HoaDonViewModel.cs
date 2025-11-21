using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QuanLyKhachSan.Models
{
    public class HoaDonViewModel
    {
        public int MaHD { get; set; }
        public string HoTen { get; set; }
        public string SoDienThoai { get; set; }
        public DateTime NgayLap { get; set; }
        public string PTTT { get; set; }
        public string TrangThai { get; set; }
        public decimal TongTienDuKien { get; set; }
    }

}