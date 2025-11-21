namespace QuanLyKhachSan.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    [Table("HoaDon")]
    public partial class HoaDon
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public HoaDon()
        {
            CT_DichVu = new HashSet<CT_DichVu>();
        }

        [Key]
        public int MaHD { get; set; }

        public int MaDP { get; set; }

        public DateTime? NgayLap { get; set; }

        [StringLength(50)]
        public string PTTT { get; set; }

        [StringLength(20)]
        public string TrangThai { get; set; }
        public decimal TongTienDuKien { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<CT_DichVu> CT_DichVu { get; set; }

        public virtual DatPhong DatPhong { get; set; }
    }
}
