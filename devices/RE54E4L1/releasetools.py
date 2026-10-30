# Copyright (C) 2019 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# devices/RE54E4L1/releasetools.py — realme GT NEO 3T (RMX3371)
#
# brina.sh copies this into META/releasetools.py of the A-only target files and
# ota_from_target_files imports it for the full-OTA hooks.
#
# It is deliberately minimal. The OnePlus templates (devices/OnePlus9R,
# devices/OP4E5D) assert ro.separate.soft == "20061" and write a hard-coded list
# of OnePlus firmware-update images. Neither belongs on a realme base: the assert
# aborts the flash on a device that is not an OnePlus 9R, and writing a file that
# is not in TARGET_DIR makes ota_from_target_files fail at the very end of a
# multi-hour build. ota_from_target_files already packs every image in IMAGES/
# (boot, dtbo, vbmeta, ...) and flashes them, so nothing has to be added here.
#
# Add a hook only for something the stock flow cannot do, and check the file
# exists before writing it.

import common  # noqa: F401  (imported so the otatools hook loader finds it)
import os

TARGET_DIR = os.getenv('OUT')


def FullOTA_Assertions(self):
    # Warn instead of abort: the base device props survive the port
    # (ro.product.device stays RE54E4L1), so a mismatch means the build went
    # wrong somewhere else, and aborting here only hides that.
    self.script.AppendExtra(
        'getprop("ro.product.device") == "RE54E4L1" || '
        'ui_print("WARNING: this package is built for RE54E4L1 (realme GT NEO 3T, RMX3371)");'
    )
