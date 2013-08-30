class Logger::SimpleFormatter
  def call(severity, time, progname, msg)
    "[#{Time.now.to_s}] [#{severity}] #{msg}\n"
  end
end

