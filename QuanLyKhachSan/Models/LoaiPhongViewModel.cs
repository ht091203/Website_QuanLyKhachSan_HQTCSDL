using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QuanLyKhachSan.Models
{
    public class LoaiPhongViewModel
    {
        public int MaLP { get; set; }
        public string TenLoai { get; set; }
        public string MoTa { get; set; }
        public decimal DonGia { get; set; }
        public int SucChua { get; set; }
        public string Anh { get; set; }
        public int SoPhongTrong { get; set; }
    }
}