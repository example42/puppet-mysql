require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'mysql::grant' do

  let(:title) { 'mysql::grant' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :ipaddress => '10.42.42.42', :grants_file => '/etc/mysql/grant.local', :concat_basedir => '/var/lib/puppet/concat'} }

  describe 'Test grant all privileges on all databases (*). Should not create the databases' do
    let(:facts) { { :mysql_root_password => 'rootpassword' } }
    let(:params) { { :name    => 'sample1',
                     :mysql_db => '*',
                     :mysql_user => 'someuser',
                     :mysql_password => 'somepassword', } }
    it { should contain_file('mysqlgrant-someuser-localhost-all.sql').with_content("# This file is managed by Puppet. DO NOT EDIT.
GRANT ALL ON *.* TO 'someuser'@'localhost' IDENTIFIED BY 'somepassword';
FLUSH PRIVILEGES ;
") }
    it { should contain_exec('mysqlgrant-someuser-localhost-*').with_command('mysql --defaults-file=/root/.my.cnf -uroot < /root/puppet-mysql/mysqlgrant-someuser-localhost-all.sql') }
  end

  describe 'Test grant all privileges on all databases (%). Should not create the databases' do
    let(:facts) { { :mysql_root_password => 'rootpassword' } }
    let(:params) { { :name    => 'sample2',
                     :mysql_db => '%',
                     :mysql_user => 'someuser',
                     :mysql_password => 'somepassword', } }
    it { should contain_file('mysqlgrant-someuser-localhost-all.sql').with_content("# This file is managed by Puppet. DO NOT EDIT.
GRANT ALL ON *.* TO 'someuser'@'localhost' IDENTIFIED BY 'somepassword';
FLUSH PRIVILEGES ;
") }
    it { should contain_exec('mysqlgrant-someuser-localhost-%').with_command('mysql --defaults-file=/root/.my.cnf -uroot < /root/puppet-mysql/mysqlgrant-someuser-localhost-all.sql') }
  end

  describe 'Test grant single privilege on single database. Should not create the databases' do
    let(:params) { { :name    => 'sample3',
                     :mysql_user => 'someuser',
                     :mysql_create_db => false,
                     :mysql_privileges => 'USAGE',
                     :mysql_host => 'somehost',
                     :mysql_password => 'somepassword', } }
    it { should contain_file('mysqlgrant-someuser-somehost-sample3.sql').with_content("# This file is managed by Puppet. DO NOT EDIT.
GRANT USAGE ON `sample3`.* TO 'someuser'@'somehost' IDENTIFIED BY 'somepassword';
FLUSH PRIVILEGES ;
") }
    it { should contain_exec('mysqlgrant-someuser-somehost-sample3').with_command('mysql -uroot < /root/puppet-mysql/mysqlgrant-someuser-somehost-sample3.sql') }
  end

  describe 'Test grant all privileges on a single database. Should create the database' do
    let(:params) { { :name    => 'sample4',
                     :mysql_db => 'sample4_db',
                     :mysql_user => 'someuser',
                     :mysql_password => 'somepassword', } }
    it { should contain_file('mysqlgrant-someuser-localhost-sample4_db.sql').with_content("# This file is managed by Puppet. DO NOT EDIT.
CREATE DATABASE IF NOT EXISTS `sample4_db`;
GRANT ALL ON `sample4_db`.* TO 'someuser'@'localhost' IDENTIFIED BY 'somepassword';
FLUSH PRIVILEGES ;
") }
    it { should contain_exec('mysqlgrant-someuser-localhost-sample4_db').with_command('mysql -uroot < /root/puppet-mysql/mysqlgrant-someuser-localhost-sample4_db.sql') }
  end

  describe 'Test grant all privileges on a single database. Should not create the database' do
    let(:params) { { :name    => 'sample5',
                     :mysql_db => 'sample5_db',
                     :mysql_create_db => false,
                     :mysql_user => 'someuser',
                     :mysql_password => 'somepassword', } }
    it { should contain_file('mysqlgrant-someuser-localhost-sample5_db.sql').with_content("# This file is managed by Puppet. DO NOT EDIT.
GRANT ALL ON `sample5_db`.* TO 'someuser'@'localhost' IDENTIFIED BY 'somepassword';
FLUSH PRIVILEGES ;
") }
  end

  describe 'Test grant all privileges on many databases using SQL wilcards. Should not create databases' do
    let(:params) { { :name    => 'sample6',
                     :mysql_db => 'sample6_db%',
                     :mysql_create_db => true,
                     :mysql_user => 'someuser',
                     :mysql_password => 'somepassword', } }
    it { should contain_file('mysqlgrant-someuser-localhost-sample6_db%.sql').with_content("# This file is managed by Puppet. DO NOT EDIT.
GRANT ALL ON `sample6_db%`.* TO 'someuser'@'localhost' IDENTIFIED BY 'somepassword';
FLUSH PRIVILEGES ;
") }
  end
  
  describe 'Test grant on a single db with create options' do
    let(:params) { { :name    => 'sample7',
                     :mysql_db => 'sample7_db',
                     :mysql_db_create_options => 'character set utf8',
                     :mysql_user => 'someuser',
                     :mysql_password => 'somepassword', } }
    it { should contain_file('mysqlgrant-someuser-localhost-sample7_db.sql').with_content(
"# This file is managed by Puppet. DO NOT EDIT.
CREATE DATABASE IF NOT EXISTS `sample7_db` character set utf8;
GRANT ALL ON `sample7_db`.* TO 'someuser'@'localhost' IDENTIFIED BY 'somepassword';
FLUSH PRIVILEGES ;
") }
  end
end
