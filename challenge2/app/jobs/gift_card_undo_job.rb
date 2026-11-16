class GiftCardUndoJob < ApplicationJob
  queue_as :normal_priority

  # Only one concurrent refund request for a transaction_id
  limits_concurrency to: 1, key: ->(site_id, transaction_id, *) {
    "#{site_id}/#{transaction_id}"
  }, duration: 5.minutes

  def perform(site_id, transaction_id, remote_transaction_id)
    transaction = GiftCardTransaction.find(transaction_id)
    site = Site.find(site_id)

    unless transaction.refundable?
      # TODO: Update this depending on the defined logger for background jobs
      $stdout.puts "GiftCardUndoJob.perform(#{site_id},#{transaction_id}): transaction is not refundable"
      return
    end

    undo_transaction(site, transaction, remote_transaction_id)
  end

  private

  def undo_transaction(site, transaction, remote_transaction_id)
    response = GiftCardService.new(
        site: site,
        card_number: transaction.card_number,
        remote_transaction_id: remote_transaction_id
    ).undo

    if response["ResponseCode"].to_i.zero?
      transaction.update_column(:refunded, true)
    else
      retry_undo(site.id, transaction.id, remote_transaction_id)
    end
  rescue
    retry_undo(site.id, transaction.id, remote_transaction_id)
  end

  def retry_undo(site_id, transaction_id, remote_transaction_id)
    GiftCardUndoJob.set(wait: 30.seconds).perform_later(site_id, transaction_id, remote_transaction_id)
  end
end
