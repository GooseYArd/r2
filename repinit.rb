#!install/bin/ruby
# -*- coding: utf-8 -*-
require 'parseconfig'
require 'socket'
require "mysql"
require 'optparse'
require 'net/ssh'
require 'ipaddr'
require 'fileutils'

$defcfg = "defaults.cfg"
$mysql_home = "/home/bailey/r2/install"

def dbenv_call(cmd)
  system("MYSQL_HOME=#{$mysql_home} PATH=install/bin:install/scripts:$PATH #{cmd}")
  if $?.exitstatus != 0
    raise 'non-zero exit status'
  end
  return true
end  

def install_cert(host)  
  fns = { 'install/data/server.crt' => "ca/%s.cert" % host,
    'install/data/server.key' => "certs/%s.key" % host,
    'install/data/root.crt' => "ca/ca-cert.pem", }
  
  fns.each { |dst, src| 
    if not File.exists?(src)
      raise 'missing certificate for this host'
    end 
    puts "Copying %s to %s" % [src, dst]
    FileUtils.cp(src, dst)
    FileUtils.chmod(0400, dst)
  }

end

def register(role, cf)
  cmd = "install/bin/repmgr -f %s --verbose %s register" % [cf, role]
  return dbenv_call(cmd)
end

def write_repmgr_conf(f, cluster, db, node, name)
  f.write("cluster=%s\n" % cluster)
  f.write("node=%d\n" % node)
  f.write("node_name=%s\n" % name )
  f.write("conninfo='host=%s user=repmgr dbname=%s'\n" % [name, db])
end

def mysql_stop()
  cmd = "mysqladmin --defaults-file=/home/bailey/r2/install/my.cnf shutdown"
  print cmd
  return dbenv_call(cmd)
end  
  
def initdb()
  cmd = "cd install && ./scripts/mysql_install_db"
  return dbenv_call(cmd)
end

def ipfor(host)
  return Socket.getaddrinfo(host, "http", nil, :STREAM)[0][2]
end

def do_query(statement)
  begin
    conn = Mysql::new(host='localhost', user='root')   
    conn.query(statement)
  rescue Mysql::Error => e
    puts "Error #{e.errno}: #{e.error}"
  ensure
    conn.close unless conn.nil?
  end
end

def remove_anonymous_users()
  do_query("DELETE FROM mysql.user WHERE User='';")
end  

def remove_remote_root()
  do_query("DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');")
end

def remove_test_database()
  do_query("DROP DATABASE test;")
end

def create_repl_user(slaves)
  slaves.each { |slave|
    ip = ip_for(slave)
    do_query("CREATE USER 'repl'@'%s' IDENTIFIED BY 'slavepass';" % ip)
    do_query("GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%s';" % ip)
  }
end

def flush_privs()
  do_query("FLUSH PRIVILEGES;")
end

def write_mysql_conf(f, role, server_id)
  
  items = { 
    'mysqld' => [["log-error", "error.log"],
                 ["pid-file", "/home/bailey/r2/install/mysql.pid"],
                 ["user", "bailey"],
                 ["innodb_buffer_pool_size", "128M"],
                 ["basedir ", " /home/bailey/r2/install"],
                 ["datadir ", " /home/bailey/r2/install/data"],
                 ["sql_mode", "NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES"],
                 ["socket", "/home/bailey/r2/install/mysql.sock"],
                 ["log-bin", "mysql-bin"],
                 ["server-id", server_id ],
                 ["innodb_flush_log_at_trx_commit","1"],
                 ["sync_binlog", "1"],
                 ["ssl-ca", "root.crt"], 
                 ["ssl-cert", "server.crt"], 
                 ["ssl-key", "server.key"],
                ],
    'client' => [
                 ["socket", "/home/bailey/r2/install/mysql.sock"],
                 ["user", "root"]
                ],    
  }
    
  items.each_pair{ |section, data| 
    f.write("[#{section}]\n")  
    data.each{ |e| f.write("#{e[0]} = #{e[1]}\n") }
  }

end

def verify_ssh(host, user)
  Net::SSH.start(host, user) do |ssh|
    ssh.open_channel do |channel|
      channel.exec("/bin/true") do |ch, success|
        unless success
          abort "FAILED: couldn't execute command (ssh.channel.exec)"
        end 
      end
    end
  end
  return true
end  

def verify_mysql_tcp(master, db, user, port=3306)
  begin
    conn = Mysql.connect(master, user, "", db)
  rescue Exception => ex
    return false
  ensure
    conn.close unless conn.nil?
  end
end

def mysql_start()
  env = { 
    "MYSQL_HOME" => $mysql_home,  
    "MYSQL_UNIX_PORT" => $mysql_sock,
    "PATH" => "/home/bailey/install/bin:/home/bailey/install/scripts:%s" % ENV['PATH']
  }
  cmd = ["/home/bailey/r2/install/bin/mysqld_safe", "--defaults-file=/home/bailey/r2/install/my.cnf"]
  pid = Process.spawn(env, 
                      cmd,
                      :out => 'flarf', 
                      :err => 'flarf.err')
  Process.detach pid
end

def readpid(pidfile)
  pidf = File.open(pidfile, 'r')
  pid = pidf.readline()
  pidf.close()
  return pid.chomp()   
end

def mysql_running()
  begin
    pidfile = "install/mysql.pid"
    if not File.exist?(pidfile)
      puts "pidfile doesn't exist"
      return false
    end
    pid = readpid(pidfile)
    Process.kill(0, Integer(pid))
  rescue Errno::ESRCH
    return false
  rescue Exception => ex
    return false
  end
  return true
end    

def get_fqdn()
  addrinfo = Socket.getaddrinfo(Socket.gethostname, nil, nil, Socket::SOCK_DGRAM, nil, Socket::AI_CANONNAME)
  af, port, myname, addr = addrinfo.first
  return myname
end

def main(args)

#  /home/bailey/r2/install/bin/mysqladmin -u root password 'new-password'
#  /home/bailey/r2/install/bin/mysqladmin -u root -h mahnmut password 'new-password'
  
  if not ENV.has_key?('MYSQL_UNIX_PORT')
    abort("MYSQL_UNIX_PORT isn't set")
  end

  opt_parser = OptionParser.new do |opt|
    opt.banner = "Usage: repinit.rb [OPTIONS]"
    opt.separator  ""
    opt.separator  "Options"
    
    opt.on("-n", "--noop", "say what youd do but dont") do
      options[:noop] = true
    end

    opt.on("-h","--help","help") do
      puts opt_parser
    end
  end

  opt_parser.parse!
  myname = get_fqdn()
  
  cfg = ParseConfig.new($defcfg)

  slaves = cfg['replication']['slaves'].split(" ")
  cluster = cfg['replication']['cluster']
  master = cfg['replication']['master']
  db = cfg['replication']['database']
  dbuser = cfg['replication']['dbuser']
  sshuser = cfg['replication']['sshuser']

  if File.exist?('install/data')
    if mysql_running()
      print("stopping mysql")
      mysql_stop()  
    end
    system('rm -rf install/data')
    Dir.mkdir("install/data")
  end

  role = nil

  if slaves.include? myname

    f = File.open("install/my.cnf", "w")
    write_mysql_conf(f, 'slave', '2')
    f.close()

    if not verify_mysql_tcp(master, db, dbuser)
      abort("Couldn't connect to master, exiting")
    end
    
    do_query("CHANGE MASTER TO MASTER_HOST='master_host_name' MASTER_USER='replication_user_name' MASTER_PASSWORD='replication_password'  MASTER_LOG_FILE='' MASTER_LOG_POS=4;")

    #if not verify_ssh(master, sshuser)
    #  abort("Couldn't make ssh connection to master")
    #end
    
    #node = slaves.index(myname) + 2
    #puts "Starting slave configuration, writing repmgr.conf"
    #write_repmgr_conf(rmf, cluster, db, node, myname)
    #rmf.close()  
    #puts "Cloning standby"
    #clone_standby(db, master, dbuser, sshuser)
    mysql_start()
    role = 'standby'
    sleep(3)

  elsif myname == master

    f = File.open("install/my.cnf", "w")
    write_mysql_conf(f, 'master', '1')
    f.close()

    puts "starting mysql_install_db..."
    initdb()
    puts "done. starting mysql..."
    mysql_start()

    puts "sleeping for 5 seconds"
    sleep(5)
    puts "started. setting up security..."
    remove_anonymous_users()
    remove_remote_root()
    remove_test_database()
    puts "done."
    create_repl_user(slaves)
    flush_privs()
    
    #install_cert(myname)

    role = 'master'

  else
    abort("I don't know what I am")
  end

  if not mysql_running()
    puts "Waiting for mysql to come up"  
    while not mysql_running()
      puts '.'
      sleep(1)
    end
  end

  #if not register(role, repmgrcfg)
  #  puts "NO"
  #end

end

main(ARGV) if $0 == __FILE__
#test() if $0 == __FILE__
