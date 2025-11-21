using QuanLyKhachSan.Models;
using System;
using System.Collections.Specialized; // thêm dòng này
using System.Web;

namespace QuanLyKhachSan.Services.VNPay
{
    public interface IVnPayService
    {
        string CreatePaymentUrl(PaymentInformationModel model, HttpContext context);
        PaymentResponseModel PaymentExecute(NameValueCollection collections);
    }
}
