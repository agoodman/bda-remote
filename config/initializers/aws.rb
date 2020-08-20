unless ENV['AWS_CLIENT_ID'].nil? || ENV['AWS_CLIENT_SECRET'].nil?
  Aws.config.update({
    region: 'us-east-1',
    credentials: Aws::Credentials.new(ENV['AWS_CLIENT_ID'], ENV['AWS_CLIENT_SECRET'])
  }) 

  Bucket = Aws::S3::Resource.new.buckets[ENV['S3_BUCKET']]
else
  Bucket = nil
end

