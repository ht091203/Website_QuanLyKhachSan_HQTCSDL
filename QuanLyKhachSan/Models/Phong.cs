namespace QuanLyKhachSan.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    [Table("Phong")]
    public partial class Phong
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Phong()
        {
            CT_DatPhong = new HashSet<CT_DatPhong>();
            CT_DichVu = new HashSet<CT_DichVu>();
        }

        [Key]
        public int MaPhong { get; set; }

        [StringLength(10)]
        public string SoPhong { get; set; }

        [StringLength(50)]
        public string ViTri { get; set; }

        [StringLength(200)]
        public string MoTa { get; set; }

        public int MaLP { get; set; }

        [StringLength(20)]
        public string TrangThai { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<CT_DatPhong> CT_DatPhong { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<CT_DichVu> CT_DichVu { get; set; }

        public virtual LoaiPhong LoaiPhong { get; set; }
    }
}
