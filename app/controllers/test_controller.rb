# controllers/test_controller.rb
class TestController < ApplicationController
  def index
    render_json_response(:ok, "Hello world", { greeting: "Hello" })
  end

  def raise_not_found
    raise ActiveRecord::RecordNotFound, "Record not found!"
  end

  def raise_invalid_record
    raise ActiveRecord::RecordInvalid.new(User.new)
  end

  def raise_standard_error
    raise StandardError, "Something went wrong"
  end
end
