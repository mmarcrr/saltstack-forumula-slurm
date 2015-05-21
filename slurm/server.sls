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
    
server:
{% if grains['os_family'] == 'RedHat' %}
   {% if grains['osmajorrelease'] == '7' %}      
  file.managed:
    - name: /usr/lib/systemd/system/slurmctld.service
    - user: root
    - group: root
    - replace: True
    - template: jinja 
    - mode: '0644'
    - source: salt://slurm/files/slurmctld.service
    - require:
       - pkg: {{ slurm.pkgSlurm }}
  service.running:
    - name: slurmctld
    - enable: True
    - reload: True
    - watch:
      - file: /usr/lib/systemd/system/slurmctld.service
  {% endif %}
{% endif %}
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
  


