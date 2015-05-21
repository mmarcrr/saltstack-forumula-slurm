{% from "slurm/map.jinja" import slurm with context %}

client:
  pkg.installed:
    - name: {{ slurm.pkgSlurm }}
    - pkgs:
      - {{ slurm.pkgSlurm }}
      - {{ slurm.pkgSlurmMuge }}
      - {{ slurm.pkgSlurmPlugins }}
    - refresh: True
  file.managed:
    - name: {{ slurm.config }}
    - user: root
    - group: root
    - mode: '644'
    - template: jinja 
    - source: salt://slurm/files/slurm.conf
  user.present:
    - name: slurm
    - uid: 550
    - gid: 510
    - gid_from_name: True
{%  if salt['pillar.get']('slurm:AuthType') in ['munge'] %}   
munge:
  pkg:
   - installed
  service:
    - running
    - name: munge
    - enable: True
    - reload: True
    - watch:
      - file: /etc/munge/munge.key
    - require:
      - pkg: {{ slurm.pkgMunge }}
      - file: /etc/munge/munge.key
  file.managed:
    - name: /etc/munge/munge.key
    - user: munge
    - group: munge
    - mode: 400
    - template: jinja
    - source: salt://slurm/files/munge.key 
    - require:
      - pkg: {{ slurm.pkgMunge }}
{% endif %}
{% if salt['pillar.get']('slurm:TopologyPlugin') in ['tree','3d_torus'] -%}
topolgy:
  file.managed:
    - name: /etc/slurm/topology.conf
    - user: root
    - group: root
    - mode: '0644'
    - source: salt://slurm/files/topology.conf
    - require:
      - pkg: {{ slurm.pkgSlurm }}
{% endif %}
{% if salt['pillar.get']('slurm:TaskPlugin') in ['cgroup'] -%}
cgroup:
  file.managed:
    - name: /etc/slurm/cgroup.conf   
    - user: root  
    - group: root
    - mode: 400
    - template: jinja
    - source: salt://slurm/files/cgroup.conf 
{% endif %}    
