class PaginationService
  def initialize(data, pagination_info, options = {})
    @data = data
    @pagination_info = pagination_info
    @options = options
    @page = pagination_info[:page].to_i
    @per_page = pagination_info[:per_page].to_i
    @offset = (@page - 1) * @per_page
  end


  def get_paginated_data
    data = @data.limit(@per_page).offset(@offset)
    serialized_data = ActiveModelSerializers::SerializableResource.new(data, @options).serializable_hash
    [ serialized_data, pagination_hash ]
  end

  def pagination_hash
    total_count = @data.size
    total_pages = (total_count.to_f / @per_page).ceil
    {
      current_page: @page,
      per_page: @per_page,
      total_pages: total_pages,
      total_count: total_count,
      next_page: @page < total_pages ? @page + 1 : nil,
      prev_page: @page > 1 ? @page - 1 : nil
    }
  end
end
