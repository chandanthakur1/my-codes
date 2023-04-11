module Api
  module V1
    class DmsDocumentsController < ApplicationController
      before_action :skip_authorization
      before_action :skip_policy_scope
      before_action :initialize_dms_service

      def documents
        received_params = params.except(:action, :controller, :dms_document, :format)
        @response = @dms_service.fetch_document_details(received_params)
        render(:documents, status: :ok)
      rescue CustomErrors => e
        CustomLogger.new(e).log_to_newrelic
        raise e
      end

      def download
        @response = @dms_service.download_document(params[:id])
        send_data @response, type: 'application/pdf', disposition: 'inline'
      rescue CustomErrors => e
        CustomLogger.new(e).log_to_newrelic
        raise e
      end

      def update_doc
        file = request.body
        @response = @dms_service.update_doc(file, params)
        render json: @response
      rescue CustomErrors => e
        CustomLogger.new(e).log_to_newrelic
        raise e
      end

      def upload_metadata
        @response = @dms_service.upload_metadata(params)
        render(:upload_metadata, status: :ok)
      rescue CustomErrors => e
        CustomLogger.new(e).log_to_newrelic
        raise e
      end

      def add_tag
        @response = @dms_service.add_tag(params[:id], params[:dms_document])
        render json: @response
      rescue CustomErrors => e
        CustomLogger.new(e).log_to_newrelic
        raise e
      end

      def delete_tag
        @response = @dms_service.delete_tag(params[:id], params[:dms_document])
        render json: @response
      rescue CustomErrors => e
        CustomLogger.new(e).log_to_newrelic
        raise e
      end

      def upload_with_metadata
        file = request.body
        @response = @dms_service.upload_with_metadata(file, params)
        render json: @response
      rescue CustomErrors => e
        CustomLogger.new(e).log_to_newrelic
        raise e
      end

      def delete_doc
        received_params = params.except(:action, :controller, :dms_document, :format)
        @response = @dms_service.delete_doc(received_params)
        render json: @response
      rescue CustomErrors => e
        CustomLogger.new(e).log_to_newrelic
        raise e
      end

      private

      def initialize_dms_service
        @dms_service = Dms::DocumentService.new
      end
    end
  end
end
