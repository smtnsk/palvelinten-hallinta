dnscrypt-proxy:
  pkg.installed: []
  service.running:
    - watch:
      - file: /etc/dnscrypt-proxy/dnscrypt-proxy.toml

/etc/dnscrypt-proxy/dnscrypt-proxy.toml:
  file.managed:
    - source: salt://dnscrypt-proxy/dnscrypt-proxy.toml

/etc/resolv.conf:
  file.managed:
    - source: salt://dnscrypt-proxy/resolv.conf
