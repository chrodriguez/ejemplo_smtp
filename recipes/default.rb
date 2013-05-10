#
# Cookbook Name:: unlp.edu
# Recipe:: default
#
# Copyright (C) 2013 CeSPI - UNLP
# 
# All rights reserved - Do Not Redistribute
#
#
package "courier-imap"

bash "create_maildir" do
  code "maildirmake /etc/skel/Maildir"
  not_if "test -d /etc/skel/Maildir"
end

user "distribuidos" do
  gid "sudo"
  shell "/bin/bash"
  home "/home/distribuidos"
  #Creado con openssl passwd -1 distribuidos
  password "$1$V5ZWhmTP$FJv67kPAacx72XNNgU7WR0"
  supports({ :manage_home => true })
end

package "bind9"

service "bind9" do
  supports [:enable, :disable, :stop, :start, :status]
  action :nothing
end

zones_dir = "/etc/bind/zones"

directory zones_dir

template "/etc/bind/named.conf.local" do
  source "named.conf.local.erb"
  owner "root"
  group "bind"
  mode "0644"
  variables(
    :prefix => "#{zones_dir}/db.",
    :zones => node[:distribuidos][:zones].keys,
    :slave_zones => node[:distribuidos][:slave_zones]
  )
  notifies :restart, "service[bind9]"
end

node[:distribuidos][:zones].each do |name,data|
  template "#{zones_dir}/db.#{name}" do
    source "zone.erb"
    owner "root"
    group "bind"
    mode "0644"
    variables(
      :domain => name,
      :data => data
    )
    notifies :restart, "service[bind9]"
  end
end

package "squirrelmail"
service "apache2" do
  supports [ :restart ]
end

link "/etc/apache2/sites-enabled/squirrelmail.conf" do
  to "/etc/squirrelmail/apache.conf"
  notifies :restart, "service[apache2]"
end

file "/etc/procmailrc" do
  content "DEFAULT=$HOME/Maildir/"
end

(1..10).each do | id |
  user "user#{id}" do
  shell "/bin/bash"
  home "/home/user#{id}"
  #Creado con openssl passwd -1 distribuidos
  password "$1$V5ZWhmTP$FJv67kPAacx72XNNgU7WR0"
  supports({ :manage_home => true })
  end
end