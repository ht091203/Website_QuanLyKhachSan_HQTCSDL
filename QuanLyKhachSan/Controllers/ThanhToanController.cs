using QuanLyKhachSan.Models;
using QuanLyKhachSan.Services.VNPay;
using System;
using System.Data.SqlClient;
using System.Web.Mvc;

namespace QuanLyKhachSan.Controllers.Admin
{
    public class ThanhToanController : Controller
    {
        private readonly VnPayService _vnPayService;
        private readonly Model1 db = new Model1();

        public ThanhToanController()
        {
            _vnPayService = new VnPayService();
        }

        public ActionResult CreatePaymentUrlVnpay(PaymentInformationModel model)
        {
            try
            {
                var url = _vnPayService.CreatePaymentUrl(model, System.Web.HttpContext.Current);
                return Redirect(url);
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Lỗi khi tạo URL thanh toán: " + ex.Message;
                return View("Error");
            }
        }

        [HttpGet]
        public ActionResult PaymentCallbackVnpay()
        {
            try
            {
                var collections = Request.QueryString;

                string responseCode = collections["vnp_ResponseCode"];
                string txnRef = collections["vnp_TxnRef"];
                string amountStr = collections["vnp_Amount"];
                string transactionNo = collections["vnp_TransactionNo"];
                string bankCode = collections["vnp_BankCode"];

                bool success = responseCode == "00";
                decimal amount = decimal.Parse(amountStr) / 100;

                if (success)
                {
                    int maDP = int.Parse(txnRef);

                    db.Database.ExecuteSqlCommand(
                        "EXEC sp_ThemPhieuCoc @p0,@p1,@p2,@p3",
                        maDP,
                        DateTime.Now,
                        amount,
                        bankCode
                    );

                    db.Database.ExecuteSqlCommand(
                        "UPDATE DatPhong SET TrangThaiCoc = N'Đã cọc' WHERE MaDP = @p0",
                        maDP
                    );
                }
                else
                {
                    int maDP = int.Parse(txnRef);
                    db.Database.ExecuteSqlCommand(
                        "UPDATE DatPhong SET TinhTrang = N'Đã huỷ' WHERE MaDP = @p0",
                        maDP
                    );
                }

                var model = new VnPayResponseModel
                {
                    OrderId = txnRef,
                    TransactionId = transactionNo,
                    Amount = amount,
                    ResponseCode = responseCode,
                    Success = success,
                    Message = success ? "Thanh toán thành công" : "Thanh toán thất bại"
                };

                return View("~/Views/ThanhToan/KetQuaThanhToan.cshtml", model);
            }
            catch (Exception ex)
            {
                System.IO.File.WriteAllText(@"C:\temp\vnpay_error.txt", ex.ToString());

                ViewBag.Error = "Lỗi xử lý callback: " + ex.Message;
                return View("Error");
            }
        }

        public ActionResult CreatePaymentUrlVnpay_Admin(PaymentInformationModel model)
        {
            try
            {
                model.ReturnUrl = Url.Action("PaymentCallbackVnpay_Admin", "ThanhToan", null, Request.Url.Scheme);

                model.Amount = Math.Round(model.Amount, 0);

                if (string.IsNullOrEmpty(model.OrderId))
                    throw new Exception("Thiếu mã đặt phòng (OrderId)");

                if (model.Amount <= 0)
                    throw new Exception("Số tiền không hợp lệ");

                var url = _vnPayService.CreatePaymentUrl(model, System.Web.HttpContext.Current);
                return Redirect(url);
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Lỗi khi tạo URL thanh toán (Admin): " + ex.Message;
                return View("Error");
            }
        }

        [HttpGet]
        public ActionResult PaymentCallbackVnpay_Admin()
        {
            try
            {
                var collections = Request.QueryString;

                string responseCode = collections["vnp_ResponseCode"];
                string txnRef = collections["vnp_TxnRef"];
                string amountStr = collections["vnp_Amount"];
                string transactionNo = collections["vnp_TransactionNo"];
                string bankCode = collections["vnp_BankCode"];

                bool success = responseCode == "00";
                decimal amount = decimal.Parse(amountStr) / 100;

                int maDP = int.Parse(txnRef);

                if (success)
                {
                    db.Database.ExecuteSqlCommand(
                        "EXEC sp_ThemPhieuCoc @MaDP, @NgayCoc, @SoTienCoc, @PTTT",
                        new SqlParameter("@MaDP", maDP),
                        new SqlParameter("@NgayCoc", DateTime.Now),
                        new SqlParameter("@SoTienCoc", amount),
                        new SqlParameter("@PTTT", "Chuyển khoản (Admin)")
                    );

                    db.Database.ExecuteSqlCommand(
                        "EXEC sp_XacNhanCheckOut @MaDP, @PTTT",
                        new SqlParameter("@MaDP", maDP),
                        new SqlParameter("@PTTT", "Chuyển khoản")
                    );

                    db.Database.ExecuteSqlCommand(
                        "UPDATE DatPhong SET TinhTrang = N'Hoàn tất', TrangThaiCoc = N'Đã cọc' WHERE MaDP = @p0",
                        maDP
                    );

                    System.Diagnostics.Debug.WriteLine($"VNPay Admin: MaDP={maDP}, Số tiền={amount}");
                }
                else
                {
                    db.Database.ExecuteSqlCommand(
                        "UPDATE DatPhong SET TinhTrang = N'Đã huỷ' WHERE MaDP = @p0",
                        maDP
                    );
                }

                var model = new VnPayResponseModel
                {
                    OrderId = txnRef,
                    TransactionId = transactionNo,
                    Amount = amount,
                    ResponseCode = responseCode,
                    Success = success,
                    Message = success ? "Thanh toán VNPay (Admin) thành công" : "Thanh toán VNPay thất bại"
                };

                return RedirectToAction("Index", "DatPhong");
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Lỗi xử lý callback (Admin): " + ex.Message;
                return View("Error");
            }
        }



    }
}
