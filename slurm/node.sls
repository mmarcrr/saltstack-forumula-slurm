{% from "slurm/map.jinja" import slurm with context %}
include: 
  - slurm
slurm_enable:
  file.directory:
    - name: /var/log/slurm/
    - user: slurm
    - group: slurm
  service.running:
    - enable: True
    - name: slurmd
    - reload: True
    - watch:
      - file: {{ slurm.config }}
    - require:
      - pkg: {{  slurm.pkgSlurm }}
      - service: munge
{% if salt['pillar.get']('slurm:CryptoType') == 'blcr' -%}
Install_pkg_checkpoint:
  pkg.installed:
    - pkgs:
      - slurm-blcr
      - blcr-modules
      - blcr
{% endif %}

 
