require "test_helper"

class Api::QuestionControllerTest < ActionDispatch::IntegrationTest
  test "should get get" do
    get api_question_get_url
    assert_response :success
  end
end
