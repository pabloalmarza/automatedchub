KOPS_CLUSTER_NAME=
KOPS_STATE_STORE=
OWNER=
NODES=
NODE_SIZE=m5d.xlarge

kops create cluster \
--node-count=${NODES} \
--node-size=${NODE_SIZE} \
--zones=us-east-1a \
--cloud-labels="OWNER=$OWNER" \
--name=${KOPS_CLUSTER_NAME}


kops update cluster --name ${KOPS_CLUSTER_NAME} --yes
