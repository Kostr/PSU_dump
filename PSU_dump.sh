for I2C_BUS in 4 5
do
  echo "Bus: ${I2C_BUS}"
  for I2C_ADDR in 61 63 64 65
  do
    if [ ! -d /sys/class/i2c-dev/i2c-${I2C_BUS}/device/${I2C_BUS}-00${I2C_ADDR} ]
    then
      echo isl68137 0x${I2C_ADDR} > /sys/class/i2c-dev/i2c-${I2C_BUS}/device/new_device
      continue
    fi
    echo -e "\tAddress: ${I2C_ADDR}"
    echo -e "\t\tLABEL\t\tLCRIT\t\tVALUE\t\tCRIT"
    for param in curr1 curr2 curr3 in1 in2 in3 power1 power2 power3 temp1 temp2 temp3;
    do
      if [ -f /sys/class/i2c-dev/i2c-${I2C_BUS}/device/${I2C_BUS}-00${I2C_ADDR}/hwmon/hwmon*/${param}_label ]
      then
        LABEL=$(cat /sys/class/i2c-dev/i2c-${I2C_BUS}/device/${I2C_BUS}-00${I2C_ADDR}/hwmon/hwmon*/${param}_label)
      else
        LABEL=${param}
      fi
      if [ -f /sys/class/i2c-dev/i2c-${I2C_BUS}/device/${I2C_BUS}-00${I2C_ADDR}/hwmon/hwmon*/${param}_lcrit ]
      then
        LCRIT=$(cat /sys/class/i2c-dev/i2c-${I2C_BUS}/device/${I2C_BUS}-00${I2C_ADDR}/hwmon/hwmon*/${param}_lcrit)
      else
        LCRIT="---"
      fi
      if [ -f /sys/class/i2c-dev/i2c-${I2C_BUS}/device/${I2C_BUS}-00${I2C_ADDR}/hwmon/hwmon*/${param}_crit ]
      then
        CRIT=$(cat /sys/class/i2c-dev/i2c-${I2C_BUS}/device/${I2C_BUS}-00${I2C_ADDR}/hwmon/hwmon*/${param}_crit)
      else
        CRIT="---"
      fi
      VALUE=$(cat /sys/class/i2c-dev/i2c-${I2C_BUS}/device/${I2C_BUS}-00${I2C_ADDR}/hwmon/hwmon*/${param}_input)

      case ${param} in
        curr1) COEFF=100
               ;;
        curr2|curr3) COEFF=10
               ;;
        *) COEFF=1
           ;;
      esac

      if [ "${LCRIT}" != "---" ]
      then
        LCRIT=$(( LCRIT*COEFF ))
      fi
      if [ "${CRIT}" != "---" ]
      then
        CRIT=$(( CRIT*COEFF ))
      fi

      case ${param} in
        curr1|curr2|curr3) DIMENSION="mA"
                           ;;
        in1|in2|in3) DIMENSION="mV"
                     ;;
        power1|power2|power3) DIMENSION="uW"
                              ;;
        temp1|temp2|temp3) DIMENSION="C"
                           ;;
        *) DIMENSION=""
           ;;
      esac

      echo -e "\t\t${LABEL}\t\t${LCRIT}\t\t${VALUE}\t\t${CRIT}\t\t${DIMENSION}"
    done
  done
done
