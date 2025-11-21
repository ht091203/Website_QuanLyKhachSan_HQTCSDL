using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QuanLyKhachSan.Models
{
    public class VnPayResponseModel
    {
        public string OrderId { get; set; }
        public string TransactionId { get; set; }
        public string ResponseCode { get; set; }
        public string Message { get; set; }
        public decimal Amount { get; set; }
        public bool Success { get; set; }
    }
}