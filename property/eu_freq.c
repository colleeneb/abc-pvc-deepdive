#include <level_zero/ze_api.h>
#include <stdio.h>
#include <stdlib.h>

void check(ze_result_t result, char *name) {
  if (result != ZE_RESULT_SUCCESS) {
    fprintf(stderr, "Error %s failed, result = %d\n", name, result);
    exit(1);
  }
}

int main() {
  check(zeInit(0), "zesInit");
  // Drivers
  uint32_t driverCount = 0;
  check(zeDriverGet(&driverCount, NULL), "zeDriverGet");
  ze_driver_handle_t *drivers = calloc(driverCount, sizeof(ze_driver_handle_t));
  check(zeDriverGet(&driverCount, drivers), "zeDriverGet");
  // Discover devices
  for (uint32_t i = 0; i < driverCount; i++) {
    uint32_t deviceCount = 0;
    check(zeDeviceGet(drivers[i], &deviceCount, NULL), "zeDeviceGet");
    ze_device_handle_t *devices = calloc(deviceCount, sizeof(ze_device_handle_t));
    check(zeDeviceGet(drivers[i], &deviceCount, devices), "zeDeviceGet");

    for (uint32_t j = 0; j < deviceCount; j++) {
      printf("Device %u\n", j);
      uint32_t subdeviceCount = 0;
      check(zeDeviceGetSubDevices(devices[i], &subdeviceCount, NULL), "zeDeviceGet");
      ze_device_handle_t *subdevices = calloc(subdeviceCount, sizeof(ze_device_handle_t));
      check(zeDeviceGetSubDevices(devices[i], &subdeviceCount, subdevices), "zeDeviceGet");

      for (uint32_t k = 0; k < subdeviceCount; k++) {
        printf("SubDevice %u\n", k);
        ze_device_properties_t deviceProperties = {};
        check(zeDeviceGetProperties(subdevices[k], &deviceProperties), "zeDeviceGetProperties");
        printf("Idle Frequency: %u \n", deviceProperties.coreClockRate);
        printf("numEUsPerSubslice: %u: numSubslicesPerSlice %u, numSlices %u, totalNumEus %u\n",
               deviceProperties.numEUsPerSubslice, deviceProperties.numSubslicesPerSlice,
               deviceProperties.numSlices,
               deviceProperties.numEUsPerSubslice * deviceProperties.numSubslicesPerSlice *
                   deviceProperties.numSlices);
      }
      free(subdevices);
    }
    free(devices);
  }
  free(drivers);
  return 0;
}
