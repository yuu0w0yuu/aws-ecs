MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="utf-8"

#!/bin/bash
#ECS Agent Setup
echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config

--//