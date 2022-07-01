yourfilenames=`ls *.yaml`
for eachfile in $yourfilenames

do
  echo $eachfile
  echo "SERVICE,CPU_LIMIT,MEMORY_LIMIT,CPU_RESERVATION,MEMORY_RESERVATION,REPLICAS"
  services=`cat $eachfile |  shyaml keys-0 services | xargs -0 -n 1 echo`
  for eachservice in $services
  do
    CPU_LIMIT=`cat $eachfile | shyaml get-value services.$eachservice.deploy.resources.limits.cpus`
    
    MEMORY_LIMIT=`cat $eachfile | shyaml get-value services.$eachservice.deploy.resources.limits.memory`
    if [[ $MEMORY_LIMIT == *"M"* ]];
      then
      MEMORY_LIMIT=`echo $MEMORY_LIMIT | sed 's/M//'`
    else
      MEMORY_LIMIT=`echo $MEMORY_LIMIT | sed 's/G//'`
      conv=1024
      MEMORY_LIMIT=$((MEMORY_LIMIT * conv))
    fi
    
    CPU_RESERVATION=`cat $eachfile | shyaml get-value services.$eachservice.deploy.resources.reservations.cpus`

    MEMORY_RESERVATION=`cat $eachfile | shyaml get-value services.$eachservice.deploy.resources.reservations.memory`
    if [[ $MEMORY_RESERVATION == *"M"* ]];
      then
      MEMORY_RESERVATION=`echo $MEMORY_RESERVATION | sed 's/M//'`
    else	    
      MEMORY_RESERVATION=`echo $MEMORY_RESERVATION | sed 's/G//'`
      conv=1024
      MEMORY_RESERVATION=$((MEMORY_RESERVATION * conv))
    fi
    
    if [ "$eachservice" = "postgres-upgrader" ]; then
      REPLICAS=1
    else
      REPLICAS=`cat $eachfile | shyaml get-value services.$eachservice.deploy.replicas`
    fi

    echo $eachservice , $CPU_LIMIT , $MEMORY_LIMIT, $CPU_RESERVATION, $MEMORY_RESERVATION, $REPLICAS
    done
echo
echo
echo
  
done
