#include <level_zero/ze_api.h>
#include <level_zero/zes_api.h>
#include <stdio.h>
#include <stdlib.h>

void check(ze_result_t result, char *name) {
  if (result != ZE_RESULT_SUCCESS) {
    fprintf(stderr, "Error %s failed, result = %d\n", name, result);
    exit(1);
  }
}

int main() {
  check(zesInit(0), "zesInit");
  // Drivers
  uint32_t driverCount = 0;
  check(zesDriverGet(&driverCount, NULL), "zesDriverGet");
  ze_driver_handle_t *drivers = calloc(driverCount, sizeof(ze_driver_handle_t));
  check(zesDriverGet(&driverCount, drivers), "zesDriverGet");
  // Discover devices
  for (uint32_t i = 0; i < driverCount; i++) {
    uint32_t deviceCount = 0;
    check(zesDeviceGet(drivers[i], &deviceCount, NULL), "zesDeviceGet");
    ze_device_handle_t *devices = calloc(deviceCount, sizeof(ze_device_handle_t));
    check(zesDeviceGet(drivers[i], &deviceCount, devices), "zesDeviceGet");

    for (uint32_t j = 0; j < deviceCount; j++) {

      ze_device_properties_t deviceProperties = {};
      check(zeDeviceGetProperties(devices[i], &deviceProperties),"zeDeviceGetProperties");
      printf("Idle Frequency: %u \n", deviceProperties.coreClockRate);
      printf("numEUsPerSubslice: %u: numSubslicesPerSlice %u, numSlices %u, totalNumEus %u\n", 
		      deviceProperties.numEUsPerSubslice,
		      deviceProperties.numSubslicesPerSlice,
		      deviceProperties.numSlices,
		      deviceProperties.numEUsPerSubslice*deviceProperties.numSubslicesPerSlice*deviceProperties.numSlices);

      uint32_t powerDomainCount = 0;
      check(zesDeviceEnumPowerDomains(devices[i], &powerDomainCount, NULL),
            "zesDeviceEnumPowerDomains");
      zes_pwr_handle_t *powerDomains = calloc(powerDomainCount, sizeof(zes_pwr_handle_t));
      check(zesDeviceEnumPowerDomains(devices[i], &powerDomainCount, powerDomains),
            "zesDeviceEnumPowerDomains");

      for (uint32_t k = 0; k < powerDomainCount; k++) {
        uint32_t powerLimitCount = 0;
        check(zesPowerGetLimitsExt(powerDomains[k], &powerLimitCount, NULL),
              "zesPowerGetLimitsExt");
        zes_power_limit_ext_desc_t *powerLimits =
            calloc(powerLimitCount, sizeof(zes_power_limit_ext_desc_t));
        check(zesPowerGetLimitsExt(powerDomains[k], &powerLimitCount, powerLimits),
              "zesPowerGetLimitsExt");

        for (uint32_t l = 0; l < powerLimitCount; l++) {
          if (powerLimits[l].level == ZES_POWER_LEVEL_SUSTAINED)
            printf("Power Level sustained Limits for device %u : %d milliwatts\n", j,
                   powerLimits[l].limit);
        }
        free(powerLimits);
      }
      free(powerDomains);
    }
    free(devices);
  }
  free(drivers);
  return 0;
}
