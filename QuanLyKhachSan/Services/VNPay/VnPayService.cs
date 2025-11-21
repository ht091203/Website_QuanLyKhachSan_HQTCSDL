using QuanLyKhachSan.Libraries;
using QuanLyKhachSan.Models;
using System;
using System.Collections.Specialized; 
using System.Configuration; 
using System.Web;

namespace QuanLyKhachSan.Services.VNPay
{
    public class VnPayService : IVnPayService
    {
        // Không cần IConfiguration nữa — dùng ConfigurationManager
        public string CreatePaymentUrl(PaymentInformationModel model, HttpContext context)
        {
            // Lấy cấu hình từ Web.config
            var timeZoneId = ConfigurationManager.AppSettings["TimeZoneId"];
            var timeZoneById = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);
            var timeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, timeZoneById);
            var tick = DateTime.Now.Ticks.ToString();

            var pay = new VnPayLibrary();

            // Lấy URL callback từ Web.config
            var urlCallBack = ConfigurationManager.AppSettings["Vnpay.PaymentBackReturnUrl"];

            // Thêm dữ liệu thanh toán
            pay.AddRequestData("vnp_Version", ConfigurationManager.AppSettings["Vnp_Version"]);
            pay.AddRequestData("vnp_Command", ConfigurationManager.AppSettings["Vnp_Command"]);
            pay.AddRequestData("vnp_TmnCode", ConfigurationManager.AppSettings["Vnp_TmnCode"]);
            pay.AddRequestData("vnp_Amount", ((int)model.Amount * 100).ToString());
            pay.AddRequestData("vnp_CreateDate", timeNow.ToString("yyyyMMddHHmmss"));
            pay.AddRequestData("vnp_CurrCode", ConfigurationManager.AppSettings["Vnp_CurrCode"]);
            pay.AddRequestData("vnp_IpAddr", pay.GetIpAddress(context));
            pay.AddRequestData("vnp_Locale", ConfigurationManager.AppSettings["Vnp_Locale"]);
            pay.AddRequestData("vnp_OrderInfo", $"{model.Name} {model.OrderDescription} {model.Amount}");
            pay.AddRequestData("vnp_OrderType", model.OrderType);
            pay.AddRequestData("vnp_ReturnUrl", ConfigurationManager.AppSettings["Vnp_PaymentBackReturnUrl"]);
            pay.AddRequestData("vnp_TxnRef", model.OrderId); 

            var paymentUrl = pay.CreateRequestUrl(
                ConfigurationManager.AppSettings["Vnp_BaseUrl"],
                ConfigurationManager.AppSettings["Vnp_HashSecret"]
            );


            return paymentUrl;
        }

        public PaymentResponseModel PaymentExecute(NameValueCollection collections)
        {
            var pay = new VnPayLibrary();
            var response = pay.GetFullResponseData(
                collections,
                ConfigurationManager.AppSettings["Vnpay.HashSecret"]
            );

            return response;
        }
    }
}
