#!install/bin/ruby
# -*- coding: utf-8 -*-
require 'parseconfig'
require 'socket'
require "pg"
require 'optparse'
require 'net/ssh'
require 'ipaddr'

defcfg = "defaults.cfg"

def pgenv_call(cmd)
  system("PATH=install/bin:$PATH #{cmd}")
  if $?.exitstatus != 0
    raise 'non-zero exit status'
  end
  return true
end  

def register(role, cf)
  cmd = "install/bin/repmgr -f %s --verbose %s register" % [cf, role]
  return pgenv_call(cmd)
end

def write_repmgr_conf(f, cluster, db, node, name)
  f.write("cluster=%s\n" % cluster)
  f.write("node=%d\n" % node)
  f.write("node_name=%s\n" % name )
  f.write("conninfo='host=%s user=repmgr dbname=%s'\n" % [name, db])
end

def pg_ctl(command)
  cmd = "install/bin/pg_ctl -D install/data %s" % command
  return pgenv_call(cmd)
end  

def initdb()
  cmd = "initdb -D install/data --locale=en_US.UTF-8 --lc-messages=sv_SE.UTF-8"
  return pgenv_call(cmd)
end

def ipfor(host)
  return Socket.getaddrinfo(host, "http", nil, :STREAM)[0][2]
end

def write_pg_hba(f, dbuser, master, slaves)
  rules = [ ['local', 'all', 'all', 'trust', nil],
            ['host', 'all', 'all', '127.0.0.1/32', 'trust'],
            ['host', 'all', 'all', '::1/128', 'trust'],    
            ['local','all', 'all', 'trust'] ]

  rules << [ 'host', 'pgbench', 'repmgr', "%s/32" % ipfor(master), 'trust' ]
 
  dbs = ['pgbench', 'repmgr']
  dbs.each { |db| 
    slaves.each { |slave| 
      rules << [ 'host', db, dbuser, "%s/32" % ipfor(slave), 'trust' ] 
    }
  }

  rules.each { |r|
    f.write("#{r[0]}\t#{r[1]}\t#{r[2]}\t#{r[3]}\t#{r[4]}\n")
  }
end

def write_postgresql_conf(f)
  f.write("listen_addresses = '*'\n")
  f.write("wal_level = 'hot_standby'\n")
  f.write("archive_mode = on\n")
  f.write("archive_command = '/bin/true'\n")
  f.write("max_wal_senders = 10\n")
  f.write("wal_keep_segments = 5000\n")
  f.write("hot_standby = on\n")
end
 
def clone_standby(db, master, dbuser, sshuser)
  cmd = "repmgr -D install/data -d %s -p 5432 -U %s -R %s --verbose standby clone %s" % [db, dbuser, sshuser, master]
  return pgenv_call(cmd)
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

def verify_pg(master, db, user, port=5432)
  conn = PGconn.connect(:host => master, 
                        :port => port,
                        :dbname => db,
                        :user => user)
end

def pg_start()
  pgenv_call("postgres -D install/data > install/data/logfile 2>&1 &")
end

def pg_running()
  begin
    pg_ctl('status')
  rescue
    return false
  end
  return true
end    


options = {}

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

myname = Socket.gethostname
cfg = ParseConfig.new(defcfg)

slaves = cfg['replication']['slaves'].split(" ")
cluster = cfg['replication']['cluster']
master = cfg['replication']['master']
db = cfg['replication']['database']
dbuser = cfg['replication']['dbuser']
sshuser = cfg['replication']['sshuser']

if File.exist?('install/data')
  if pg_running()
    pg_ctl('stop')  
  end
  system('rm -rf install/data')
end

repmgrcfg = "install/etc/repmgr.conf"
rmf = File.new(repmgrcfg, 'w')
role = nil

if slaves.include? myname

  if not verify_pg(master, db, dbuser)
    abort("Couldn't connect to master, exiting")
  end
  
  if not verify_ssh(master, sshuser)
    abort("Couldn't make ssh connection to master")
  end
  
  node = slaves.index(myname) + 2
  puts "Starting slave configuration, writing repmgr.conf"
  write_repmgr_conf(rmf, cluster, db, node, myname)
  rmf.close()  
  puts "Cloning standby"
  clone_standby(db, master, dbuser, sshuser)
  pg_start()
  role = 'standby'
  sleep(3)

elsif myname == master

  initdb()
  f = File.open("install/data/pg_hba.conf", "w")
  write_pg_hba(f, dbuser, master, slaves)
  f.close()

  f = File.open("install/data/postgresql.conf", "w")
  write_postgresql_conf(f)
  f.close()
  
  pg_start()
  sleep(10)
  pgenv_call("createuser --login --superuser --replication repmgr")
  pgenv_call("createdb pgbench")
  pgenv_call("pgbench -i -s 10 pgbench")
  write_repmgr_conf(rmf, cluster, db, 1, myname)
  rmf.close()
  role = 'master'
else
  abort("I don't know what I am")
end

if not register(role, repmgrcfg)
  puts "NO"
end
