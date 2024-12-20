
#!/bin/bash
for service in $(supervisorctl status | grep -v asterisk | awk '{print $1}'); do
    supervisorctl restart "$service"
done
