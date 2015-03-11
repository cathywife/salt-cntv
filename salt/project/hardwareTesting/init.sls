/root/testSuite:
  file.recurse:
    - source: salt://project/hardwareTesting/files
    - user: root
    - group: root
    - file_mode: 0755
    - dir_mode: 0755
    - exclude_pat: E@\.svn
    - makedirs: True

hardwareTesting_pkg:
  pkg.installed:
    - names:
      - gcc
      - libaio-devel
      - sysbench
      - gcc-c++
      - screen
      - time
      - dmidecode

hardwareTesting_motd:
  file.managed:
    - name: /etc/motd
    - user: root
    - group: root
    - template: jinja
    - contents: |
        Hardware:
        PRD: {{grains["manufacturer"]}} {{grains["productname"]}}({{grains["serialnumber"]}})
        CPU: {{salt['cmd.run']('echo $[`cat /proc/cpuinfo |grep "physical id" |sed "s/physical id\t*: //g" |sort -r |head -n1`+1]')}}way(s) {{salt['cmd.run']('cat /proc/cpuinfo |grep "cpu cores" |sed "s/cpu cores\t*: //g" |sort -r |head -n1')}}core(s) {{grains["num_cpus"]}}thread(s) {{grains["cpu_model"]}}
        MEM: {{grains["mem_total"]}}MiB
        MEM_DIMM: {{ salt['cmd.run']('dmidecode -t memory |grep -P "^\tSpeed: [0-9]+ MHz" |wc -l') }}/{{ salt['cmd.run']('dmidecode -t memory |grep -P "^\s*Locator:" |wc -l') }}
        MEM_model: {{ salt['cmd.run']('dmidecode -t memory |grep -P "^\tSize: [0-9]+ MB|Part Number: [^\s|Not]" |sed "s/\t\|Size: \|Part Number: //g"')|replace(" MB\n","MB ")|indent(8+11) }}
        RAID: {{ salt['cmd.run']('lspci |grep "RAID bus controller" |sed "s/.* RAID bus controller: //g"')|indent(8+6) }}
        HDD: *cpoy the file, replace after*
        NIC: {{ salt['cmd.run']('lspci |grep "Ethernet controller:" |sed "s/.* Ethernet controller: //g"')|indent(8+5) }}
        POWER: *cpoy the file, replace after*
        
        Environment:
        OS: {{grains["osfullname"]}}-{{grains["osrelease"]}} {{grains["kernelrelease"]}}
        RAID: *cpoy the file, replace after*
        FS: {{ salt['cmd.run']('df -T -h |grep -v "^tmpfs"')|indent(8+4) }}

hardwareTesting_unTar:
  cmd.run:
    - name: "cd /root/testSuite/src; ls *.gz |while read file; do tar zxf $file; done"
    - user: root
    - unless: "[ -d /root/testSuite/src/fio-2.1.7 ]"
    - require:
       - file: /root/testSuite 

hardwareTesting_installFio:
  cmd.run:
    - name: "cd /root/testSuite/src/fio-2.1.7; make && make install"
    - user: root
    - unless: "[ -x /usr/local/bin/fio ]"
    - require:
       - file: /root/testSuite
       - pkg: hardwareTesting_pkg

hardwareTesting_installMbw:
  cmd.run:
    - name: "cd /root/testSuite/src/mbw-1.3; make && cp mbw /usr/local/bin/"
    - user: root
    - unless: "[ -x /usr/local/bin/mbw ]"
    - require:
       - file: /root/testSuite
       - pkg: hardwareTesting_pkg

hardwareTesting_installIperf:
  cmd.run:
    - name: "cd /root/testSuite/src/iperf-2.0.5; ./configure; make && make install"
    - user: root
    - unless: "[ -x /usr/local/bin/iperf ]"
    - require:
       - file: /root/testSuite
       - pkg: hardwareTesting_pkg