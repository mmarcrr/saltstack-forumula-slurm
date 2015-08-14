{% from "slurm/map.jinja" import slurm with context %}
include:
  - slurm
{% if salt['pillar.get']('slurm:AccountingStorageType') in ['slurmdbd'] %}
  - slurm.slurmdbd
{% endif %}
server_log_file:
  file.managed:
    - name: {{ salt['pillar.get']('slurm:SlurmctldLogFile','/var/log/slurm/slurmctld.log') }}
    - user: slurm
    - group: slurm
    - dir_user: slurm
    - file_mode: 755
    - dir_mode: 777
    - makedirs: True
    - require:
      - pkg: {{ slurm.pkgMunge }}
      - user: slurm

Bug_rpm_no_create_default_environment:
  file.touch:
    - name: /etc/default/slurmctld
    - onlyif:  'test ! -e /etc/default/slurmctld'



server:
  service.running:
    - name: slurmctld
    - enable: True
    - reload: True
    - require:
      - file: Bug_rpm_no_create_default_environment



slurm_disable:
  service.dead:
    - enable: false
    - name: slurm
    - reload: True
    - watch:
      - file: {{ slurm.config }}
    - require:
      - pkg: {{  slurm.pkgSlurm }}
      - service: munge
  


