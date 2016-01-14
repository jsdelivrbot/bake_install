#!/usr/bin/env ruby

require 'rbconfig'

BAKE_VERSION = "0.1.1"

def osx_install_deps
    system("brew --version")
    if $?.exitstatus != 0
      raise "Homebrew not installed"
    end
    puts "=> Preparing to install bake"
    # Install fwup
    puts "=> Updating Homebrew Deps"

    system("brew update")
    if $?.exitstatus != 0
      raise "Could not update homebrew. Please run brew doctor and try again."
    end
    system("brew install fwup")
    system("brew install squashfs")
end

def linux_install_deps
    system("fwup --version >/dev/null")
    if $?.exitstatus != 0
      raise "fwup v0.5.0 or later required. See https://github.com/fhunleth/fwup"
    end

    system("mksquashfs -version >/dev/null")
    if $?.exitstatus != 0
      raise "mksquashfs required. Install squashfs-tools. E.g. sudo apt-get install squashfs-tools"
    end
end

def install_bake(install_prefix, bake_home)
    puts "=> Creating bake home"
    system("mkdir -p #{bake_home}")

    puts "=> Downloading latest bake"
    system("curl -o #{bake_home}/bake.tar.gz -L https://s3.amazonaws.com/bakeware/bake/bake-#{BAKE_VERSION}.tar.gz")

    system("mkdir -p #{install_prefix}")
    if $?.exitstatus != 0
      raise "Error creating installation directory #{install_prefix}"
    end

    system("tar -xf #{bake_home}/bake.tar.gz -C #{install_prefix}")
    if $?.exitstatus != 0
      raise "Bake did not install correctly. Check permissions on #{install_prefix}."
    end

    system("rm #{bake_home}/bake.tar.gz")

    puts "=> bake version #{BAKE_VERSION} installed to #{install_prefix}"
end

host_os = RbConfig::CONFIG['host_os']
case host_os
when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
    raise "Sorry, Windows support isn't implemented yet."
when /darwin|mac os/
    osx_install_deps
    install_bake('/usr/local/bin', '~/.bake')
when /linux/
    home_dir = '~/.bake'
    install_dir = home_dir + '/bin'

    linux_install_deps
    install_bake(install_dir, home_dir)

    puts "Be sure to add #{install_dir} to your path"
else
    raise "Sorry, support for #{host_os.inspect} isn't implemented yet."
end
