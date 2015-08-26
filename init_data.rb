require 'hiredis'
require 'redis'
require 'mysql2-cs-bind'
require 'json'

db = Mysql2::Client.new(
  host: ENV['ISU4_DB_HOST'] || 'localhost',
  port: ENV['ISU4_DB_PORT'] ? ENV['ISU4_DB_PORT'].to_i : nil,
  username: ENV['ISU4_DB_USER'] || 'root',
  password: ENV['ISU4_DB_PASSWORD'],
  database: ENV['ISU4_DB_NAME'] || 'isu4_qualifier',
  reconnect: true,
)

redis = Redis.new(
  :host   => "127.0.0.1",
  :port   => 6379,
  :driver => :hiredis
)

fail_users  = Hash.new(0)
fail_ips    = Hash.new(0)
last_logins = {}

puts "start cache data"

db.xquery("select * from login_log").each do |log|
  user_id, login, ip, success, created_at = log.values_at('user_id', 'login', 'ip', 'succeeded', 'created_at')

  if success == 1
    fail_ips[ip]       = 0
    fail_users[login]  = 0
    last_logins[login] = {ip: ip, created_at: created_at}
  else
    fail_ips[ip]      += 1
    fail_users[login] += 1 if user_id
  end
end

last_logins.each do |k, v|
  redis.set("isu4:last_login:#{k}", v.to_json)
end

fail_ips.each do |k, v|
  redis.set("isu4:fail_ip:#{k}", v)
end

fail_users.each do |k, v|
  redis.set("isu4:fail_user:#{k}", v)
end

puts "finish cache data"
