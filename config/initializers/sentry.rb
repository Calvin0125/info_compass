Sentry.init do |config|
  config.dsn = 'https://1eaab729f1c24d65b8134c37a0daf77e@o936036.ingest.sentry.io/5886111'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 0.5
end
