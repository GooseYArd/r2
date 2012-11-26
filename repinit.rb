#!install/bin/ruby
require 'parseconfig'
require 'socket'
require "pg"
require 'optparse'
require 'net/ssh'

defcfg = "defaults.cfg"

def register(role, cf)
  cmd = "PATH=install/bin:$PATH install/bin/repmgr -f %s --verbose %s register" % [cf, role]
  puts cmd
  system(cmd)
  if $?.exitstatus != 0
    return false
  end
  return true
end

def write_repmgr_conf(f, cluster, db, node, name)
  f.write("cluster=%s\n" % cluster)
  f.write("node=%d\n" % node)
  f.write("node_name=%s\n" % name )
  f.write("conninfo='host=%s user=repmgr dbname=%s'\n" % [name, db])
end

def pg_ctl(command)
  cmd = "install/bin/pg_ctl -D install/data %s" % command
  system(cmd)
  if $?.exitstatus != 0
    return false
  end
  return true
end  

def clone_standby(db, master, dbuser, sshuser)
  cmd = "PATH=install/bin/$PATH install/bin/repmgr -D install/data -d %s -p 5432 -U %s -R %s --verbose standby clone %s" % [db, dbuser, sshuser, master]
  system(cmd)
  if $?.exitstatus != 0
    return false
  end
  return true
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
  system("install/bin/postgres -D install/data > install/data/logfile 2>&1 &")
end

options = {}

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: repinit.rb [OPTIONS]"
  opt.separator  ""
  opt.separator  "Options"

  opt.on("-f","--force","wipe existing data?") do
    options[:force] = true
  end

  opt.on("-c","--clean","wipe existing data?") do
    options[:clean] = true
  end

  opt.on("-h","--help","help") do
    puts opt_parser
  end
end

opt_parser.parse!

myname = Socket.gethostname
cfg = ParseConfig.new(defcfg)

slaves = cfg['replication']['slaves']
cluster = cfg['replication']['cluster']
master = cfg['replication']['master']
db = cfg['replication']['database']
dbuser = cfg['replication']['dbuser']
sshuser = cfg['replication']['sshuser']

if options[:clean]
  pg_ctl('stop')
  system('rm -rf install/data')
end

repmgrcfg = "install/etc/repmgr.conf"
if File.exist?(repmgrcfg)
  if options[:force]
    File.unlink(repmgrcfg)
  else
    abort("%s already exists" % repmgrcfg)
  end
end

if pg_ctl('status')
  if options[:force]
    warn("postgres is running, stopping postmaster")
    pg_ctl('stop')
  else
    abort("postmaster is still running")
  end
end

rmf = File.new(repmgrcfg, 'w')
role = nil

if not verify_pg(master, db, dbuser)
  abort("Couldn't connect to master, exiting")
end

if not verify_ssh(master, sshuser)
  abort("Couldn't make ssh connection to master")
end
  
if slaves.include? myname
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
  write_repmgr_conf(rmf, cluster, db, 1, myname)
  rmf.close()
  role = 'master'
else
  abort("I don't know what I am")
end

if not register('standby', repmgrcfg)
  puts "NO"
end
