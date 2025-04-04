# logsentry
emails alerts for failed login attempts on Linux systems 

- Looks at /var/log/auth.log which requires rsyslog to be enabled on the system. 

- Uses msmtp with gmail for the reporting, so a config with .msmtprc has to be done. 
    - Be sure to generate an app password from gmail instead of using your actual password.


              defaults
        auth           on
        tls            on
        tls_trust_file /etc/ssl/certs/ca-certificates.crt
        logfile        ~/.msmtp.log
        
        account        gmail
        host           smtp.gmail.com
        port           587
        from           your.email@gmail.com
        user           your.email@gmail.com
        password       your_app_password_here
        
        account default : gmail

- This should send an alert to your email once a threshold of attempts is reached. 
