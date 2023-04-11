
  class LapDmsDocumentIdsJob < ApplicationJob
    attr_accessor :transaction, :params

    def perform(params)
      Rails.logger.info "LapDmsDocumentIdsJob =>  :: Entry #{params.to_json}"
      @params = params
      set_transaction_object
      
      fetch_itr_doc_document_ids
      fetch_pan_doc_document_ids
      fetch_property_doc_document_ids
    end

    def set_transaction_object
      @transaction = LoanAgainstProperty::Transaction.find(params[:transaction_id])
      return false if @transaction.nil?
    rescue StandardError => e
      Rails.logger.error "LapDocumentWaitJob :: Document Not found, #{e.message}"
      false
    end

    def fetch_itr_doc_document_ids
      return unless transaction.co_borrower_info&.itr_doc.present?
      transaction.co_borrower_info.itr_doc.each do |doc|
        next unless doc['file_ids'].present?
        doc['file_ids'].each do |file_id|
          dms = Dms::DocumentService.new
          params = {}
          params['doc_type'] = 'itr'
          params['doc_sub_type'] = 'itr_co_brw'
          params['file_id'] = file_id
          params['platform'] = 'loans'
          params['instrument'] = 'lap'
          params['title'] = 'Co-borrower Income Tax Returns'
          params['transaction_id'] = id.to_s
          params['borrower_id'] = User.current_user.entity.id.to_s
          params['time_period'] = doc['year'] if doc['year'].present?
          params['user_id'] = User.current_user.id.to_s
          doc['doc_ids'] << dms.upload_metadata(params)['id']
        end
      end
    end

    def fetch_pan_doc_document_ids
      return unless transaction.co_borrower_info&.pan_doc.present?
      return unless transaction.co_borrower_info&.pan_doc['file_ids'].present?
      co_borrower_info.pan_doc['file_ids'].each do |file|
        dms = Dms::DocumentService.new
        params = {}
        params['doc_type'] = 'kyc'
        params['doc_sub_type'] = 'pan_card_the_co_brw'
        params['file_id'] = file
        params['platform'] = 'loans'
        params['instrument'] = 'lap'
        params['title'] = 'PAN Card of the Co-Borrower'
        params['transaction_id'] = id.to_s
        params['borrower_id'] = User.current_user.entity.id.to_s
        params['user_id'] = User.current_user.id.to_s
        co_borrower_info.pan_doc['doc_ids'] << dms.upload_metadata(params)['id']
      end
    end

    def fetch_property_doc_document_ids
      return unless transaction.property_data.present?
      transaction.property_data.each do |prop_data|
        next unless prop_data&.property_documents.present?
        prop_data.property_documents.each do |doc|
          next unless doc['file_ids'].present?
          doc['file_ids'].each do |file|
            dms = Dms::DocumentService.new
            params = {}
            params['doc_type'] = doc['document_type'] == 'utility_bills' ? 'utility_bill' : 'property_document'
            params['doc_sub_type'] = DOC_TYPES_MP_TO_DMS[doc['document_type'].to_sym]
            params['file_id'] = file
            params['platform'] = 'loans'
            params['instrument'] = 'lap'
            params['title'] = PROPERTY_DOCUMENTS_TITLES_DMS[doc['document_type'].to_sym]
            params['transaction_id'] = id.to_s
            params['borrower_id'] = User.current_user.entity.id.to_s
            params['user_id'] = User.current_user.id.to_s
            doc['doc_ids'] << dms.upload_metadata(params)['id']
          end
        end
      end
    end
  end