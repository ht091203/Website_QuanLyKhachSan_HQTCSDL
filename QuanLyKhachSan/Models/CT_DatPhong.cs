namespace QuanLyKhachSan.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    public partial class CT_DatPhong
    {
        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int MaDP { get; set; }

        [Key]
        [Column(Order = 1)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int MaPhong { get; set; }

        public decimal? DonGia { get; set; }

        public int? SoNgayO { get; set; }

        public decimal? ThanhTien { get; set; }

        public virtual DatPhong DatPhong { get; set; }

        public virtual Phong Phong { get; set; }
    }
}
