{% from "epazote/map.jinja" import conf with context %}

fetch_epazote:
{% if grains['os_family'] == 'FreeBSD' %}
  pkg.installed:
    - name: epazote
{% elif grains['os_family'] == 'Debian' %}
  cmd.run:
    - name: {{ conf.name }}
    - unless:
      - test -x {{ conf.unless }}
{% endif %}

{{ conf.get('sv-dir') }}/run:
  file.managed:
    - mode: 755
    - makedirs: True
    - template: jinja
    - source: salt://epazote/files/run

{{ conf.get('sv-dir') }}/log/run:
  file.managed:
    - mode: 755
    - makedirs: True
    - source: salt://epazote/files/log_run

{{ conf.get('sv-dir') }}/log/main:
  file.directory:
    - makedirs: True

epazote:
  service:
    - running
    - provider: runit
    - watch:
      - file: epazote
  file.managed:
    - name: {{ conf.get('etc-path', '/usr/local/etc') }}/epazote.yml
    - template: jinja
    - makedirs: True
    - source: salt://epazote/files/{{ pillar.get('epazote_conf', 'generic') }}.yml

{{ conf.get('SVDIR', '/service') }}/epazote:
  file.symlink:
    - target: {{ conf.get('sv-dir') }}
