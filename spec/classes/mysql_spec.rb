#!/usr/bin/env rspec
require 'spec_helper'

describe 'mysql' do

  let(:title) { 'mysql' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :ipaddress => '10.42.42.42' } }

  describe 'Test standard installation' do
    it { should contain_package('mysql').with_ensure('present') }
    it { should contain_service('mysql').with_ensure('running') }
    it { should contain_service('mysql').with_enable('true') }
    it { should contain_file('mysql.conf').with_ensure('present') }
  end

  describe 'Test installation of a specific version' do
    let(:params) { {:version => '1.0.42' } }
    it { should contain_package('mysql').with_ensure('1.0.42') }
  end

  describe 'Test standard installation with monitoring and firewalling' do
    let(:params) { {:monitor => true , :firewall => true, :port => '42' } }

    it { should contain_package('mysql').with_ensure('present') }
    it { should contain_service('mysql').with_ensure('running') }
    it { should contain_service('mysql').with_enable('true') }
    it { should contain_file('mysql.conf').with_ensure('present') }
    it { should contain_monitor__process('mysql_process').with_enable('true') }
    it { should contain_firewall('mysql_tcp_42').with_enable('true') }
  end

  describe 'Test decommissioning - absent' do
    let(:params) { {:absent => true, :monitor => true , :firewall => true, :port => '42'} }

    it 'should remove Package[mysql]' do should contain_package('mysql').with_ensure('absent') end
    it 'should not define Service[mysql]' do should_not contain_service('mysql') end
    it 'should remove mysql configuration file' do should contain_file('mysql.conf').with_ensure('absent') end
    it { should contain_file('mysql.conf').without_notify }
    it { should contain_monitor__process('mysql_process').with_enable('false') }
    it { should contain_firewall('mysql_tcp_42').with_enable('false') }
  end

  describe 'Test decommissioning - disable' do
    let(:params) { {:disable => true, :monitor => true , :firewall => true, :port => '42'} }

    it { should contain_package('mysql').with_ensure('present') }
    it 'should stop Service[mysql]' do should contain_service('mysql').with_ensure('stopped') end
    it 'should not enable at boot Service[mysql]' do should contain_service('mysql').with_enable('false') end
    it { should contain_file('mysql.conf').with_ensure('present') }
    it { should contain_monitor__process('mysql_process').with_enable('false') }
    it { should contain_firewall('mysql_tcp_42').with_enable('false') }
  end

  describe 'Test decommissioning - disableboot' do
    let(:params) { {:disableboot => true, :monitor => true , :firewall => true, :port => '42'} }

    it { should contain_package('mysql').with_ensure('present') }
    it { should_not contain_service('mysql').with_ensure('present') }
    it { should_not contain_service('mysql').with_ensure('absent') }
    it 'should not enable at boot Service[mysql]' do should contain_service('mysql').with_enable('false') end
    it { should contain_file('mysql.conf').with_ensure('present') }
    it { should contain_monitor__process('mysql_process').with_enable('false') }
    it { should contain_firewall('mysql_tcp_42').with_enable('true') }
  end

  describe 'Test customizations - template' do
    let(:params) { {:template => "mysql/spec.erb" , :options => { 'opt_a' => 'value_a' } } }

    it { should contain_file('mysql.conf').with_content(/fqdn: rspec.example42.com/) }
    it { should contain_file('mysql.conf').with_content(/value_a/) }
  end

  describe 'Test customizations - source' do
    let(:params) { {:source => "puppet://modules/mysql/spec" , :source_dir => "puppet://modules/mysql/dir/spec" , :source_dir_purge => true } }

    it { should contain_file('mysql.conf').with_source('puppet://modules/mysql/spec') }
    it { should contain_file('mysql.dir').with_source('puppet://modules/mysql/dir/spec') }
    it { should contain_file('mysql.dir').with_purge('true') }
  end

  describe 'Test customizations - custom class' do
    let(:params) { {:my_class => "mysql::spec" } }
    it { should contain_file('mysql.conf').with_content(/fqdn: rspec.example42.com/) }
  end

  describe 'Test service autorestart' do
    it { should contain_file('mysql.conf').with_notify('Service[mysql]') }
  end

  describe 'Test service autorestart' do
    let(:params) { {:service_autorestart => "no" } }
    it { should contain_file('mysql.conf').without_notify(nil) }
  end

  describe 'Test Puppi Integration' do
    let(:params) { {:puppi => true, :puppi_helper => "myhelper"} }
    it { should contain_puppi__ze('mysql').with_helper('myhelper') }
  end

  describe 'Test Monitoring Tools Integration' do
    let(:params) { {:monitor => true, :monitor_tool => "puppi" } }
    it { should contain_monitor__process('mysql_process').with_tool('puppi') }
  end

  describe 'Test Firewall Tools Integration' do
    let(:params) { {:firewall => true, :firewall_tool => "iptables" , :protocol => "tcp" , :port => "42" } }
    it { should contain_firewall('mysql_tcp_42').with_tool('iptables') }
  end

  describe 'Test OldGen Module Set Integration' do
    let(:params) { {:monitor => "yes" , :monitor_tool => "puppi" , :firewall => "yes" , :firewall_tool => "iptables" , :puppi => "yes" , :port => "42" } }

    it { should contain_monitor__process('mysql_process').with_tool('puppi') }
    it { should contain_firewall('mysql_tcp_42').with_tool('iptables') }
    it { should contain_puppi__ze('mysql').with_ensure('present') }
  end

  describe 'Test params lookup' do
    let(:facts) { { :monitor => true , :ipaddress => '10.42.42.42' } }
    let(:params) { { :port => '42' } }

    it { should contain_monitor__process('mysql_process').with_enable('true') }
  end

  describe 'Test params lookup' do
    let(:facts) { { :mysql_monitor => true , :ipaddress => '10.42.42.42' } }
    let(:params) { { :port => '42' } }

    it { should contain_monitor__process('mysql_process').with_enable('true') }
  end

  describe 'Test params lookup' do
    let(:facts) { { :monitor => false , :mysql_monitor => true , :ipaddress => '10.42.42.42' } }
    let(:params) { { :port => '42' } }

    it { should contain_monitor__process('mysql_process').with_enable('true') }
  end

  describe 'Test params lookup' do
    let(:facts) { { :monitor => false , :ipaddress => '10.42.42.42' } }
    let(:params) { { :monitor => true , :firewall => true, :port => '42' } }

    it { should contain_monitor__process('mysql_process').with_enable('true') }
  end

  describe 'Test do not manage service status' do
    let(:params) { { :service_manage => false } }

    it { should contain_service('mysql').with_ensure(nil) }
  end

end

