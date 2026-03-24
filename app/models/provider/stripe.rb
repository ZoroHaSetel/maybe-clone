class Provider::Stripe
  Error = Class.new(StandardError)

  def initialize(secret_key:, webhook_secret:)
    @client = Stripe::StripeClient.new(secret_key)
    @webhook_secret = webhook_secret
  end

  def process_event(event_id)
    event = retrieve_event(event_id)

    case event.type
    when /^customer\.subscription\./
      # Subscription processing removed
      Rails.logger.warn "Subscription event ignored: #{event.type}"
    else
      Rails.logger.warn "Unhandled event type: #{event.type}"
    end
  end

  def process_webhook_later(webhook_body, sig_header)
    thin_event = client.parse_thin_event(webhook_body, sig_header, webhook_secret)
    StripeEventHandlerJob.perform_later(thin_event.id)
  end

  def create_checkout_session(plan:, family_id:, family_email:, success_url:, cancel_url:)
    # Subscription checkout removed
    raise Error, "Subscription checkout not available"
  end

  def get_checkout_result(session_id)
    # Subscription checkout result removed
    CheckoutSessionResult.new(success?: false, subscription_id: nil)
  end

  def create_billing_portal_session_url(customer_id:, return_url:)
    # Billing portal removed
    raise Error, "Billing portal not available"
  end

  def update_customer_metadata(customer_id:, metadata:)
    client.v1.customers.update(customer_id, metadata: metadata)
  end

  private
    attr_reader :client, :webhook_secret

    NewCheckoutSession = Data.define(:url, :customer_id)
    CheckoutSessionResult = Data.define(:success?, :subscription_id)

    def price_id_for(plan)
      # Subscription pricing removed
      nil
    end

    def retrieve_event(event_id)
      client.v1.events.retrieve(event_id)
    end
end
