

default['ulimit']['pam_su_template_cookbook'] = nil
default['ulimit']['users'] = {
  :minerops => {
  :filehandle_limit => 'ulimited' # optional
  :filehandle_soft_limit => 8192, # optional; not used if filehandle_limit is set)
  :filehandle_hard_limit => 8192, # optional; not used if filehandle_limit is set)
  :process_limit => 61504, # optional
  :process_soft_limit => 61504, # optional; not used if process_limit is set)
  :process_hard_limit => 61504, # optional; not used if process_limit is set)
  :memory_limit => 1024,# optional
  :core_limit => 2048, # optional
  :core_soft_limit => 1024, # optional
  :core_hard_limit => 'unlimited', # optional
  :stack_soft_limit => 2048, # optional
  :stack_hard_limit => 2048 # optional
  },
  :ubuntu => {
  :filehandle_limit => 8192, # optional
  :filehandle_soft_limit => 8192, # optional; not used if filehandle_limit is set)
  :filehandle_hard_limit => 8192, # optional; not used if filehandle_limit is set)
  :process_limit => 61504, # optional
  :process_soft_limit => 61504, # optional; not used if process_limit is set)
  :process_hard_limit => 61504, # optional; not used if process_limit is set)
  :memory_limit => 1024,# optional
  :core_limit => 2048, # optional
  :core_soft_limit => 1024, # optional
  :core_hard_limit => 'unlimited', # optional
  :stack_soft_limit => 2048, # optional
  :stack_hard_limit => 2048 # optional
  }
}
default['ulimit']['security_limits_directory'] = '/etc/security/limits.d'

