.pragma library

var user_access_map = {
  "users": {
    "user_1": {
      "user_access_channels": [
        "channel_A"
      ]
    },
    "user_2": {
      "user_access_channels": [
        "channel_B",
        "channel_C"
      ]
    },
    "user_3": {
      "user_access_channels": [
        "channel_A",
        "channel_B"
      ]
    },
    "admin": {
      "user_access_channels": ["*"]
    }
  }
}
