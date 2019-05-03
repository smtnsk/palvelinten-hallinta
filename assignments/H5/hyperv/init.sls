{% set script = 'create-vm.ps1' %}
{% set dest = 'C:\\' ~ script %}

{{ dest }}:
  file.managed:
    - source: salt://hyperv/{{ script }}

Set-ExecutionPolicy:
  cmd:
    - run
    - shell: powershell
    - name: "Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser"

{{ script }}:
  cmd:
    - run
    - shell: powershell
    - name: {{ dest }}
