require 'vcr'
require 'webmock'

VCR.configure do |config|
    config.cassette_library_dir = "spec/vcr_cassettes"
    config.hook_into :webmock
    config.configure_rspec_metadata!
    config.ignore_localhost = true
    config.default_cassette_options = { record: :once, re_record_interval: 7.days } # カセットの有効期限は作成から7日間
    config.filter_sensitive_data('<CHATGPT_API_KEY>') { ENV['CHATGPT_API_KEY'] }
    config.allow_http_connections_when_no_cassette = ENV['DISABLE_VCR'] == 'true' # 無効化切り替え
end
