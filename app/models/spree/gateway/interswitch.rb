require "offsite_payments"
module Spree
  class Gateway::Interswitch < Gateway
    preference :merchant_code, :string
    preference :test_gateway_id, :string
    preference :live_gateway_id, :string

      
    def provider_class
      ::OffsitePayments.integration('Interswitch')
    end

    def provider
      #assign payment mode
      OffsitePayments.mode = preferred_test_mode == true ? :test : :production
      provider_class
    end

    def gateway_id
      #assign payment mode
      preferred_test_mode == true ? preferred_test_gateway_id : preferred_live_gateway_id
    end
    def frontend_script
      preferred_test_mode == true ? 'https://sanbox.interswitchgroup.com/paymentgateway/public/js/webpay.js' : 'https://www.interswitchgroup.com/paymentgateway/public/js/webpay.js'
    end

    def verify_endpoint
      preferred_test_mode == true ? 'https://sandbox.interswitchng.com/collections/api/v1/gettransaction.json?' : 'https://webpay.interswitchng.com/collections/api/v1/gettransaction.json?'
    end

    def auto_capture?
      true
    end

    def method_type
      "interswitch"
    end

    def support?(source)
      true
    end

    def authorization
      self
    end

    def purchase(amount, source, gateway_options={})
      ActiveMerchant::Billing::Response.new(true, "Interswitch success")
    end

    def success?
      true
    end

    def txnid(order)
      order.id.to_s + order.number.to_s
    end

    def service_provider
      "interswitch"
    end

   
    def amount_ok?(order_total, pg_amount)
      BigDecimal.new(pg_amount) == order_total
    end

    def source_required?
      false
    end
  end
end