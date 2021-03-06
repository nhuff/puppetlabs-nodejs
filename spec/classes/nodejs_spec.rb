require 'spec_helper'

describe 'nodejs', :type => :class do

  describe 'when deploying on debian' do
    let :facts do
      {
        :operatingsystem => 'Debian',
        :lsbdistcodename => 'sid',
      }
    end

    it { should contain_class('apt') }
    it { should contain_apt__source('sid').with({
      'location' => 'http://ftp.us.debian.org/debian/',
    }) }
    it { should contain_package('nodejs').with({
      'name'    => 'nodejs',
      'require' => 'Anchor[nodejs::repo]',
    }) }
    it { should contain_package('npm').with({
      'name'    => 'npm',
      'require' => 'Anchor[nodejs::repo]',
    }) }
    it { should_not contain_package('nodejs-stable-release') }
  end

  describe 'when deploying on ubuntu' do
    let :facts do
      {
        :operatingsystem => 'Ubuntu',
        :lsbdistcodename => 'edgy',
      }
    end

    let :params do
      { :dev_package => true, }
    end

    it { should contain_class('apt') }
    it { should contain_apt__ppa('ppa:chris-lea/node.js') }
    it { should contain_package('nodejs') }
    it { should contain_package('nodejs').with({
      'name'    => 'nodejs',
      'require' => 'Anchor[nodejs::repo]',
    }) }
    it { should contain_package('nodejs-dev') }
    it { should contain_package('npm').with({
      'name'    => 'npm',
      'require' => 'Anchor[nodejs::repo]',
    }) }
    it { should_not contain_package('nodejs-stable-release') }
  end

  { 'Redhat' => 'el',
    'CentOS' => 'el',
    'Fedora' => 'fedora',
    'Amazon' => 'amzn1'
  }.each do |os, repo|
    describe 'when deploying on RedHat' do
      let :facts do
        { :operatingsystem => os, }
      end

      let :params do
        { :dev_package => true, }
      end

      it { should contain_package('nodejs-stable-release').with({
        'source'   => "http://nodejs.tchol.org/repocfg/#{repo}/nodejs-stable-release.noarch.rpm",
        'provider' => 'rpm',
      }) }
      it { should contain_package('nodejs').with({
        'name'    => 'nodejs-compat-symlinks',
        'require' => 'Anchor[nodejs::repo]',
      }) }
      it { should contain_package('npm').with({
        'name'    => 'npm',
        'require' => 'Anchor[nodejs::repo]',
      }) }
      it { should_not contain_package('nodejs-dev') }
    end
  end

  describe 'when deploying with proxy' do
    let :facts do
      {
        :operatingsystem => 'Ubuntu',
        :lsbdistcodename => 'edgy',
      }
    end

    let :params do
      { :proxy => 'http://proxy.puppetlabs.lan:80/' }
    end

    it { should contain_package('npm').with({
      'name'    => 'npm',
      'require' => 'Anchor[nodejs::repo]',
    }) }
    it { should contain_exec('npm_proxy').with({
      'command' => 'npm config set proxy http://proxy.puppetlabs.lan:80/',
      'require' => 'Package[npm]',
    }) }
    it { should_not contain_package('nodejs-stable-release') }
  end

  describe 'when pkg_src is specified' do
    let :facts do 
      {
        :operatingsystem => 'RedHat'
      }
    end

    let :params do
      {
        :pkg_src => 'http://pkg.puppetlabs.com/nodejs-release.noarch.rpm'
      }
    end
    it { should contain_package('nodejs-stable-release').with({
      'source' => 'http://pkg.puppetlabs.com/nodejs-release.noarch.rpm'
    }) }
  end
  describe 'when with_repo is false' do
    let :facts do 
      {
        :operatingsystem => 'RedHat'
      }
    end

    let :params do
      {
        :with_repo => false
      }
    end

    it {
      should_not contain_package('nodejs-stable-release')
    }
  end
end

