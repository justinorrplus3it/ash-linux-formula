# STIG URL: http://www.stigviewer.com/stig/red_hat_enterprise_linux_6/2014-06-11/finding/V-38543
# Finding ID:	V-38543
# Version:	RHEL-06-000184
# Finding Level:	Low
#
#     The audit system must be configured to audit all discretionary access 
#     control permission modifications using chmod. The changing of file 
#     permissions could indicate that a user is attempting to gain access 
#     to information that would otherwise be disallowed. Auditing DAC 
#     modifications can facilitate the identification of patterns of abuse 
#     among both authorized and unauthorized users. 
#
############################################################

script_V38543-describe:
  cmd.script:
  - source: salt://STIGbyID/cat3/files/V38543.sh

# Monitoring of SELinux DAC config
{% if salt['file.search']('/etc/audit/audit.rules', '-a always,exit -F arch=b64 -S chmod -F auid>=500 -F auid!=4294967295 -k perm_mod -a always,exit -F arch=b64 -S chmod -F auid=0 -k perm_mod') %}
file_V38543-auditRules_selDAC:
  cmd.run:
  - name: 'echo "Appropriate audit rule already in place"'
{% elif salt['file.search']('/etc/audit/audit.rules', '/etc/selinux/') %}
file_V38543-auditRules_selDAC:
  file.replace:
  - name: '/etc/audit/audit.rules'
  - pattern: '^.*/etc/selinux/.*$'
  - repl: '-a always,exit -F arch=b64 -S chmod -F auid>=500 -F auid!=4294967295 -k perm_mod -a always,exit -F arch=b64 -S chmod -F auid=0 -k perm_mod'
{% else %}
file_V38543-auditRules_selDAC:
  file.append:
  - name: '/etc/audit/audit.rules'
  - text:
    - '# Monitor /etc/selinux/ for changes (per STIG-ID V-38543)'
    - '-a always,exit -F arch=b64 -S chmod -F auid>=500 -F auid!=4294967295 -k perm_mod -a always,exit -F arch=b64 -S chmod -F auid=0 -k perm_mod'
{% endif %}
