/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
.pragma library

/* The invalid device_id value */
const NULL_DEVICE_ID = "NULL";

/* The debug device_id value */
const DEBUG_DEVICE_ID = "DEBUG";

/* Guest account properties */
const GUEST_USER_ID = "Guest";
const GUEST_FIRST_NAME = "First";
const GUEST_LAST_NAME = "Last";

/* Controller type designation */
const DEVICE_CONTROLLER_TYPES = {
    EMBEDDED: 0x01,
    ASSISTED: 0x02,
}
