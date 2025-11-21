namespace QuanLyKhachSan.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    [Table("DatPhong")]
    public partial class DatPhong
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public DatPhong()
        {
            CT_DatPhong = new HashSet<CT_DatPhong>();
            HoaDons = new HashSet<HoaDon>();
            PhieuCocs = new HashSet<PhieuCoc>();
        }

        [Key]
        public int MaDP { get; set; }

        public int MaKH { get; set; }

        [Column(TypeName = "date")]
        public DateTime NgayDat { get; set; }

        public DateTime? ThoiGianNhanPhong { get; set; }

        public DateTime? ThoiGianTraPhongDuKien { get; set; }
        public DateTime? ThoiGianNhanPhongThucTe { get; set; }
        public DateTime? ThoiGianTraPhongThucTe { get; set; }

        [StringLength(50)]
        public string TinhTrang { get; set; }

        public decimal? TongTienDuKien { get; set; }

        [StringLength(20)]
        public string TrangThaiCoc { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<CT_DatPhong> CT_DatPhong { get; set; }

        public virtual KhachHang KhachHang { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<HoaDon> HoaDons { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<PhieuCoc> PhieuCocs { get; set; }
    }
}
