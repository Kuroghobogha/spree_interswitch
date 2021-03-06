require 'net/http'
require 'json'
require "uri"

module Spree
  class InterswitchController < StoreController
    protect_from_forgery only: :index
    @productinfo = 'apparel'
    
    def index
      @furl = interswitch_cancel_url
      payment_method = Spree::PaymentMethod.find(params[:payment_method_id])
      @payment_method_id = payment_method.id 
      
      @merchant_code = payment_method.preferred_merchant_code
     
      @gateway_id = payment_method.gateway_id
      @script = payment_method.frontend_script
      @gateway_mode = payment_method.gateway_mode

      @txnid = payment_method.txnid(current_order)
      @amount = current_order.total * 100
      @checkout_amount = current_order.total
      @email = current_order.email
      @currency = current_order.currency
      
      payment_method_id_string = @payment_method_id.to_s
      @surl = interswitch_confirm_url + '?isw_reference=' + @txnid + '&payment_method_id=' + payment_method_id_string
      
      if(address = current_order.bill_address || current_order.ship_address)
        @phone = address.phone #udf2
        @firstname = address.firstname
        @lastname = address.lastname #udf1
        @city = address.city #udf3
      end
      
      @service_provider = payment_method.service_provider
    end

    def confirm
      payment_method = Spree::PaymentMethod.find(params[:payment_method_id])
       Spree::LogEntry.create({
        source: payment_method,
        details: params.to_yaml
      })
      
      order = current_order || raise(ActiveRecord::RecordNotFound)
      
      if(address = order.bill_address || order.ship_address)
        firstname = address.firstname
      end
      
      verify_endpoint = payment_method.verify_endpoint
      merchant_code = payment_method.preferred_merchant_code
     
      reference = params[:isw_reference]
      amount = (order.total*100).to_i
      amount = amount.to_s
      url = verify_endpoint+'merchantcode='+ merchant_code + '&transactionreference='+reference+ '&amount='+amount
      uri = URI(url)
      response = Net::HTTP.get(uri)
      response = JSON.parse(response)
      if (response['ResponseCode'] != '00')
        flash.alert = 'Transaction Verification Failed:'+ response['ResponseDescription']
      else
        
        payment = order.payments.create!({
          source_type: 'Spree::Gateway::Interswitch',
          amount: order.total,
          payment_method: payment_method, 
          avs_response:reference,
          number:reference
        })

        #mark payment as paid/complete
        payment.complete

        order.next
        order.update_attributes({:state => "complete", :completed_at => Time.now})
        # redirect_to checkout_state_path(order.state)
      end
                    
      if order.complete?
         # order.update!
        flash.notice = Spree.t(:order_processed_successfully)

        redirect_to order_path(order)
        return
      else
        redirect_to checkout_state_path(order.state)
        return
      end
    end

    def cancel
      #log some entry into table
      Spree::LogEntry.create({
        source: 'Spree::Gateway::Interswitch',
        details: params.to_yaml
      })
      
      flash[:notice] = "Don't want to use Interswitch? No problems."
      #redirect to payment path and ask user to complete checkout
      #with different payment method
      redirect_to checkout_state_path(current_order.state)
    end
    
    private
    def payment_method_id
      params[:udf4]
    end
  end
end