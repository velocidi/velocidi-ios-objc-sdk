@import JSONModel;
@class VSDKVoucher;

@interface VSDKTransaction : JSONModel

/**
  Transaction identifier (REQUIRED)
 */ @property (nonnull) NSString *transactionId;

/**
  Transaction total price (after taxes and shipping)
 */
@property float price;

/**
  Transaction frequency using cron format (https://crontab.guru/)
 */
@property NSString *recurrence;

/**
  Transaction currency
 */
@property NSString *currency;

/**
  Transaction tax
 */
@property float tax;

/**
  Transaciton shipping cost
 */
@property float shipping;

/**
  Voucher used in this transaction 
 */
@property VSDKVoucher *voucher;

/**
  Payment type (e.g. credit card, debit card, Paypal)
 */
@property NSString *paymentMethod;

/**
  Additional information about the payment
 */
@property NSString *paymentDetails;

@end
