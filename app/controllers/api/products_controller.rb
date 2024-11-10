module Api
  class ProductsController < ApplicationController
    def import
      raise NoImportFileError unless params[:import_file].present?

      import_file_content = JSON(params[:import_file])

      render json: import_file_content, status: 200
    rescue NoImportFileError => e
      render json: e.message, status: :bad_request
    end
  end
end
