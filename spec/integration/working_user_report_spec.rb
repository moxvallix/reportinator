class User
  require "active_support"
  require "active_model"

  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :id
  attribute :first_name
  attribute :last_name
end

PARAMS = {id: 1, first_name: "Test", last_name: "User"}

Reportinator.configure do |config|
  config.report_directories = ["spec/reports"]
  config.report_suffixes = ["test.json"]
end

RSpec.describe "A working user report" do
  context "given a valid model, params and reportinator config" do
    it "outputs correct information" do
      user = User.new(PARAMS)
      report = Reportinator::Loader.data_from_template("test_user", {variables: {user: user}})
      output = [[PARAMS[:id], PARAMS[:first_name], PARAMS[:last_name]]]
      expect(report).to eq(output)
    end
  end
end
