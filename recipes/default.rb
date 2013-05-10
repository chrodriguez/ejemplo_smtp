#
# Cookbook Name:: unlp.edu
# Recipe:: default
#
# Copyright (C) 2013 CeSPI - UNLP
# 
# All rights reserved - Do Not Redistribute
#
#
#

all = []

locales "es_ES.ISO-8859-1 ISO-8859-1" do
  action :add
end

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
  all << "distribuidos"
end

package "bind9"

service "bind9" do
  supports [:enable, :disable, :stop, :start, :status]
  action :nothing
end

zones_dir = "/var/cache/bind/"

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
      :data => data,
      :ipaddress => node[:distribuidos][:my_ipaddress] || node[:ipaddress]
    )
    notifies :restart, "service[bind9]"
  end
end

package "squirrelmail"

file "/etc/squirrelmail/config_local.php" do
  content "<?php\n$squirrelmail_default_language = 'es_ES';\n$theme_default = #{rand(52)};$provider_name = $org_name='#{node["fqdn"]}';\n$domain='#{node["postfix"]["mydomain"]}';\n"
  mode "0644"
end

service "apache2" do
  supports [ :restart ]
end

link "/etc/apache2/sites-enabled/squirrelmail.conf" do
  to "/etc/squirrelmail/apache.conf"
  notifies :restart, "service[apache2]"
end

link "/etc/postfix/cacert.pem" do
  to "/etc/ssl/certs/Equifax_Secure_CA.pem"
end

file "/etc/procmailrc" do
  content "DEFAULT=$HOME/Maildir/"
end

(1..10).each do | id |
  user "usuario#{id}" do
  shell "/bin/bash"
  home "/home/user#{id}"
  #Creado con openssl passwd -1 distribuidos
  password "$1$V5ZWhmTP$FJv67kPAacx72XNNgU7WR0"
  supports({ :manage_home => true })
  end
  all << "usuario#{id}"
end


bash "mod_rewrite" do
  command "a2enmod rewrite"
end

file "/etc/apache2/sites-enabled/redirect.conf" do
  content "RedirectMatch ^/$ /squirrelmail"
  notifies :restart, "service[apache2]"
end

node.set[:postfix][:aliases] = {'todos' => all }

include_recipe "postfix::aliases"
