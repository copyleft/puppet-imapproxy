# == Class: imapproxy
#
# This class can be called directly or included through other classes
#
# === Parameters
#
# [*ensure*]
#   Valid values are absent and present
#
# [*template*]
#   Define which template file to use
#
# [*server_hostname*]
#    Define which server_hostname should be used with imapproxy
#
# === Authors
#
# Frank Solli <frank.solli@copyleft.no>
#
class imapproxy (
  $ensure = present,
  $template = 'imapproxy/imapproxy.conf.erb',
  $server_hostname = '',
)

{

  validate_string($server_hostname)
  validate_re($ensure, ['^present$', '^absent$'], "${ensure} not supported.")

  if $server_hostname == '' {
    fail('The address of the IMAP-server must be defined')
  }

  if $ensure == 'present' {
    $service_enable = true
    $service_running = running
    $package_ensure = present
    $config_ensure = present

  }  else {
    $service_enable = false
    $service_running = stopped
    $package_ensure = absent
    $config_ensure = absent
  }

  file{ '/etc/imapproxy.conf':
    ensure  => $config_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($template);
  }

  package{ 'imapproxy':
    ensure  => $package_ensure,
    require => File['/etc/imapproxy.conf'];
  }

  service{ 'imapproxy':
    ensure    => $service_running,
    enable    => $service_enable,
    require   => Package['imapproxy'],
    subscribe => File['/etc/imapproxy.conf'],
    hasstatus => true;
  }
}
