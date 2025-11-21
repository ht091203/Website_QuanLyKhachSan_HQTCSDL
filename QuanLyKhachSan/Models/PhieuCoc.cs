namespace QuanLyKhachSan.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    [Table("PhieuCoc")]
    public partial class PhieuCoc
    {
        [Key]
        public int MaPC { get; set; }

        public int MaDP { get; set; }

        [Column(TypeName = "date")]
        public DateTime? NgayCoc { get; set; }

        public decimal SoTienCoc { get; set; }

        [StringLength(50)]
        public string PTTT { get; set; }

        public virtual DatPhong DatPhong { get; set; }
    }
}
