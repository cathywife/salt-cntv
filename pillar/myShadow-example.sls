myShadow:
  serviceName:
    secretString:
      - "admin:XXXXXXXXX"
      - "user:XXXXXXXX"
  system:
    username:
      roles:
        - beaver-apiWeb
        - beaver-syslog
        - beaver-weiboWeb
      home: "/usr/lib/python2.6/site-packages/beaver"
      shell: "/sbin/nologin"
