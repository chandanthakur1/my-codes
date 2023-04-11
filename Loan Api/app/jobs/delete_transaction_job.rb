# class DeleteTransactionJob < ApplicationJob
class DeleteTransactionJob < ApplicationJob
  queue_as ENV['LOANS_WORKER_QUEUE']

  def perform()
    return unless Rails.env.staging?
    transactions = Transaction.where(:created_at.lt => 6.months.ago)
    Rails.logger.info "DeleteTransactionJob deal count= #{transactions.count}"
    transaction_ids = transactions.pluck(:_id)
    sliced_transaction_ids = transaction_ids.each_slice(50).to_a
    
    sliced_transaction_ids.each do |sliced_transaction_id|
      Transactions::DeleteEachTransactionJob.perform_later({transaction_ids: sliced_transaction_id}.to_json)
    end
    Rails.logger.info "Six Months Ago Data Deleted"
  end
end
