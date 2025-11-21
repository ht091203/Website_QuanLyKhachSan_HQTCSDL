using System;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity;
using System.Linq;

namespace QuanLyKhachSan.Models
{
    public partial class Model1 : DbContext
    {
        public Model1()
            : base("name=Model11")
        {
        }

        public virtual DbSet<CT_DatPhong> CT_DatPhong { get; set; }
        public virtual DbSet<CT_DichVu> CT_DichVu { get; set; }
        public virtual DbSet<DatPhong> DatPhongs { get; set; }
        public virtual DbSet<DichVu> DichVus { get; set; }
        public virtual DbSet<HoaDon> HoaDons { get; set; }
        public virtual DbSet<KhachHang> KhachHangs { get; set; }
        public virtual DbSet<LoaiPhong> LoaiPhongs { get; set; }
        public virtual DbSet<NhanVien> NhanViens { get; set; }
        public virtual DbSet<PhieuCoc> PhieuCocs { get; set; }
        public virtual DbSet<Phong> Phongs { get; set; }
        public virtual DbSet<TaiKhoan> TaiKhoans { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Entity<DatPhong>()
                .HasMany(e => e.CT_DatPhong)
                .WithRequired(e => e.DatPhong)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<DatPhong>()
                .HasMany(e => e.HoaDons)
                .WithRequired(e => e.DatPhong)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<DatPhong>()
                .HasMany(e => e.PhieuCocs)
                .WithRequired(e => e.DatPhong)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<DichVu>()
                .HasMany(e => e.CT_DichVu)
                .WithRequired(e => e.DichVu)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<HoaDon>()
                .HasMany(e => e.CT_DichVu)
                .WithRequired(e => e.HoaDon)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<KhachHang>()
                .HasMany(e => e.DatPhongs)
                .WithRequired(e => e.KhachHang)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<LoaiPhong>()
                .HasMany(e => e.Phongs)
                .WithRequired(e => e.LoaiPhong)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<Phong>()
                .HasMany(e => e.CT_DatPhong)
                .WithRequired(e => e.Phong)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<Phong>()
                .HasMany(e => e.CT_DichVu)
                .WithRequired(e => e.Phong)
                .WillCascadeOnDelete(false);
        }
    }
}
