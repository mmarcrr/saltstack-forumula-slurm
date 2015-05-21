{% from "slurm/map.jinja" import slurm with context %}
include: 
  - slurm
 

{% if grains['os_family'] == 'RedHat' %}
   {% if grains['osmajorrelease'] == '7' %}  
service_slurm_bug:
  file.managed:    
    - name:  /usr/lib/systemd/system/slurm.service
    - user: root
    - group: root
    - mode: '0644'
    - template: jinja 
    - replace: True
    - source: salt://slurm/files/slurmd.service
    - require:
        - pkg: {{ slurm.pkgSlurm }}
        
delete_old_init:     
  file.absent:
    - name: /etc/init.d/slurm
          
  {% endif %}
{% endif %}

slurm_enable:
  file.directory:
    - name: /var/log/slurm/
    - user: slurm
    - group: slurm
  service.running:
    - enable: True
    - name: slurm
    - reload: True
    - watch:
      - file: {{ slurm.config }}
    - require:
      - pkg: {{  slurm.pkgSlurm }}
      - service: munge
 
