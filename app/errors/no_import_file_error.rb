class NoImportFileError < StandardError
  def message
    'There seems to be no imported file, please verify and try again'
  end
end
