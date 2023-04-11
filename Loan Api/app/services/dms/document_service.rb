# frozen_string_literal: true
require 'net/http'
class Dms::DocumentService

  

  def upload_metadata(params)
    request = Net::HTTP::Post.new("#{url}/document/data")
    request.body = {
      "doc_sub_type": params['doc_sub_type'].to_s,
      "doc_type": params['doc_type'].to_s,
      "file_id": params['file_id'].to_s,
      "platform": params['platform'].to_s,
      "tags": fetch_tags(params),
      "title": params['title'].to_s,
      "user_id": params['user_id'].to_s
    }.to_json
    request['Content-Type'] = 'Application/Json'
    response = Net::HTTP.start(url.hostname, url.port, req_options) do |http|
      http.request(request)
    end
    unless response.code == '200'
      Rails.logger.error "dms::FileService :: upload_metadata :: params => #{params}, code => #{response.code}, error_message => #{response.body}"
      raise Dms::FileService::ResponseError, response.body
    end
    JSON.parse(response.body)
  end



  def fetch_document_details(received_params)
    filter = filter_incoming_params(received_params)
    request = Net::HTTP::Get.new("#{url}/documents?#{filter}")
    request['Api-Key'] = ENV['dms_api_key']
    response = Net::HTTP.start(url.hostname, url.port, req_options) do |http|
      http.request(request)
    end
    if response.code == '200'
      return JSON.parse(response.body)
    elsif response.code == '400'
      raise CustomErrors::BadRequest, "Make Sure the data are correct"
    elsif response.code == '404'
      raise CustomErrors::NotFound, "Make Sure the data are correct"
    else
      raise CustomErrors::InternalServerError, "Internal Server Errors"
    end
  end

  def download_document(file_id)
    request = Net::HTTP::Get.new("#{url}/files/#{file_id}/download")
    request['Api-Key'] = ENV['dms_api_key']
    response = Net::HTTP.start(url.hostname, url.port, req_options) do |http|
      http.request(request)
    end
    if response.code == '200'
      return response.body
    elsif response.code == '400'
      raise CustomErrors::BadRequest, "Make Sure the data are correct"
    elsif response.code == '404'
      raise CustomErrors::NotFound, "Request Data Not found"
    else
      raise CustomErrors::InternalServerError, "Internal Server Errors"
    end
  end

  def update_dms_file(file, params)
    raise CustomErrors::BadRequest, "File is required" if !params[:file].present?
    filename = validate_file(params)
    form_data = {
      'file' => UploadIO.new(file, 'application/pdf', filename)
    }

    form_data['documentId'] = params[:documentId] if params[:documentId].present?
    form_data['previousFileId'] = params[:previousFileId] if params[:previousFileId].present?

    request = Net::HTTP::Post::Multipart.new("#{url}/files/upload", form_data)
    request['Api-Key'] = ENV['dms_api_key']
    response = Net::HTTP.start(url.hostname, url.port, req_options) do |http|
      http.request(request)
    end
    if response.code == '200'
      return JSON.parse(response.body)
    elsif response.code == '400'
      raise CustomErrors::BadRequest, "Make Sure the data are correct"
    elsif response.code == '404'
      raise CustomErrors::NotFound, "Make Sure the data are correct"
    else
      raise CustomErrors::InternalServerError, "Internal Server Errors"
    end
  end

  def update_doc(file, params)
    raise CustomErrors::BadRequest, 'Make sure the Data are correct' unless params[:curr_cir_doc_id].present?
    params[:tags] = "cir_doc_id_#{params[:curr_cir_doc_id]}"
    doc_params = params.except(:action, :controller, :dms_document, :format, :file, :documentId, :previousFileId, :curr_cir_doc_id)
    docs = fetch_document_details(doc_params)
    raise CustomErrors::NotFound, "Doc Id not Found" if docs["total"] == 0
    doc = docs['documents'][0]
    params[:documentId] = doc['id']
    params[:previousFileId] = doc['files'][0]['id']
    response = { file_id: update_dms_file(file, params), cir_doc_id: "cir_doc_id_#{params[:new_cir_doc_id]}"}
    delete_tag(params[:documentId], { 'tag_type' => 'cir_doc_id', 'tag_value' => params[:curr_cir_doc_id]})
    add_tag(params[:documentId], { 'tag_type' => 'cir_doc_id', 'tag_value' => params[:new_cir_doc_id]})
  end

  def add_tag(doc_id, params)
    request = Net::HTTP::Put.new("#{url}/documents/#{doc_id}/add-tag?tag_type=#{params['tag_type']}&tag_value=#{params['tag_value']}")
    request['Api-Key'] = ENV['dms_api_key']
    response = Net::HTTP.start(url.hostname, url.port, req_options) do |http|
      http.request(request)
    end
    if response.code == '200'
      return JSON.parse(response.body)
    elsif response.code == '400'
      raise CustomErrors::BadRequest, "Make Sure the data are correct"
    elsif response.code == '404'
      raise CustomErrors::NotFound, "Make Sure the data are correct"
    else
      raise CustomErrors::InternalServerError, "Internal Server Errors"
    end
  end

  def delete_tag(doc_id, param)
    params = ''
    params = param['tag_type'] + '_' + param['tag_value'] if param['tag_type'].present? && param['tag_value'].present?
    request = Net::HTTP::Put.new("#{url}/documents/#{doc_id}/delete-tag?tag_name=#{params}")
    request['Api-Key'] = ENV['dms_api_key']
    response = Net::HTTP.start(url.hostname, url.port, req_options) do |http|
      http.request(request)
    end
    if response.code == '200'
      return JSON.parse(response.body)
    elsif response.code == '400'
      raise CustomErrors::BadRequest, "Make Sure the data are correct"
    elsif response.code == '404'
      raise CustomErrors::NotFound, "Make Sure the data are correct"
    else
      raise CustomErrors::InternalServerError, "Internal Server Errors"
    end
  end

  def upload_with_metadata(file, params)
    file_id = update_dms_file(file, params)
    metadata = fetch_metadata_from_params(params, file_id)
    request = Net::HTTP::Post.new("#{url}/document/data")
    request.body = metadata
    request['Content-Type'] = 'Application/Json'
    response = Net::HTTP.start(url.hostname, url.port, req_options) do |http|
      http.request(request)
    end
    if response.code == '200'
      return JSON.parse(response.body)
    elsif response.code == '400'
      raise CustomErrors::BadRequest, "Make Sure the data are correct"
    elsif response.code == '404'
      raise CustomErrors::NotFound, "Make Sure the data are correct"
    else
      raise CustomErrors::InternalServerError, "Internal Server Errors"
    end
  end

  def delete_doc(params)
    doc_id = ''
    if params[:curr_cir_doc_id].present?
      params[:tags] = "cir_doc_id_#{params[:curr_cir_doc_id]}"
      doc = fetch_document_details(params.except(:curr_cir_doc_id))
      raise CustomErrors::NotFound, "Doc Id not Found" if doc["total"] == 0
      doc_id = doc['documents'][0]['id']
    else
      doc_id = params[:doc_id]
    end
    request = Net::HTTP::Delete.new("#{url}/documents/#{doc_id}")
    request['Api-Key'] = ENV['dms_api_key']
    response = Net::HTTP.start(url.hostname, url.port, req_options) do |http|
      http.request(request)
    end
    if response.code == '200'
      return JSON.parse(response.body)
    elsif response.code == '400'
      raise CustomErrors::BadRequest, "Make Sure the data are correct"
    elsif response.code == '404'
      raise CustomErrors::NotFound, "Make Sure the data are correct"
    else
      raise CustomErrors::InternalServerError, "Internal Server Errors"
    end
  end

  private

  def filter_incoming_params(received_params)
    return '' unless received_params.present?
    query_string = ''
    received_params.each do |key, value|
      query_string += "#{key}=#{value}&"
    end
    query_string.chomp!('&')
  end

  def req_options
    { use_ssl: url.scheme == 'https' }
  end

  def validate_file(params)
    unless params[:file].present?
      Rails.logger.error 'dms::FileService :: error_message => No File is Selected'
      raise 'No File is Selected'
    end
    uploaded_file = params[:file]
    uploaded_file.original_filename
  end

  def fetch_metadata_from_params(params, file_id)
    tags = []
    tags << { tag_type: 'entity_id', tag_value: params[:entity_id] } if params[:entity_id].present?
    tags << { tag_type: 'borrower_id', tag_value: params[:borrower_id] } if params[:borrower_id].present?
    tags << { tag_type: 'lender_id', tag_value: params[:lender_id] } if params[:lender_id].present?
    tags << { tag_type: 'deal_id', tag_value: params[:deal_id] } if params[:deal_id].present?
    tags << { tag_type: 'order_id', tag_value: params[:order_id] } if params[:order_id].present?
    tags << { tag_type: 'category', tag_value: params[:category] } if params[:category].present?
    tags << { tag_type: 'verified_by', tag_value: params[:verified_by] } if params[:verified_by].present?
    tags << { tag_type: 'order_stage', tag_value: params[:order_stage] } if params[:order_stage].present?
    tags << { tag_type: 'order_sub_stage', tag_value: params[:order_sub_stage] } if params[:order_sub_stage].present?
    tags << { tag_type: 'time_period', tag_value: params[:time_period] } if params[:time_period].present?
    tags << { tag_type: 'source', tag_value: params[:source] } if params[:source].present?
    tags << { tag_type: 'instrument', tag_value: params[:instrument] } if params[:instrument].present?
    tags << { tag_type: 'knowledge_graph', tag_value: 'deal' } if params[:knowledge_graph].present?
    tags << { tag_type: 'gst_number', tag_value: params[:gst_number] } if params[:gst_number].present?
    tags << { tag_type: 'fsa_type', tag_value: params[:fsa_type] } if params[:fsa_type].present?
    tags << { tag_type: 'person_id', tag_value: params[:person_id] } if params[:person_id].present?
    tags << { tag_type: 'doc_side', tag_value: params[:doc_side] } if params[:doc_side].present?
    tags << { tag_type: 'bank_account_number', tag_value: params[:bank_account_number] } if params[:bank_account_number].present?
    tags << { tag_type: 'cir_doc_id', tag_value: params[:cir_doc_id] } if params[:cir_doc_id].present?

    output = {
      doc_sub_type: params[:doc_sub_type],
      doc_type: params[:doc_type],
      file_id: file_id['id'],
      platform: params[:platform],
      tags: tags,
      title: params[:title],
      user_id: params[:user_id]
    }
    output.to_json
  end
end
