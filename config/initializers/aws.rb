unless ENV['AWS_CLIENT_ID'].nil? || ENV['AWS_CLIENT_SECRET'].nil?
  Aws.config.update({
    region: ENV['AWS_REGION'],
    credentials: Aws::Credentials.new(ENV['AWS_CLIENT_ID'], ENV['AWS_CLIENT_SECRET'])
  }) 
end

