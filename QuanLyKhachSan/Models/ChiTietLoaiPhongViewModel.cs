using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QuanLyKhachSan.Models
{
    public class ChiTietLoaiPhongViewModel
    {
        public LoaiPhongViewModel LoaiPhong { get; set; }
        public List<PhongViewModel> DanhSachPhongTrong { get; set; }
    }
}