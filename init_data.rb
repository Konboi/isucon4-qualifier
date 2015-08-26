require 'hiredis'
require 'redis'
require 'mysql2-cs-bind'

db = Mysql2::Client.new(
  host: ENV['ISU4_DB_HOST'] || 'localhost',
  port: ENV['ISU4_DB_PORT'] ? ENV['ISU4_DB_PORT'].to_i : nil,
  username: ENV['ISU4_DB_USER'] || 'root',
  password: ENV['ISU4_DB_PASSWORD'],
  database: ENV['ISU4_DB_NAME'] || 'isu4_qualifier',
  reconnect: true,
)

db.xquery("select * from login_log").each do |log|
  puts log
end
