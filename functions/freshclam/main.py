import os
from datetime import datetime

import freshclam


def update_virus_definitions(data, context):
    """ Cloud function to update clamav virus definitions in cloud storage bucket
    """
    start_time = datetime.utcnow()
    print("Started at %s\n" % (start_time.strftime("%Y/%m/%d %H:%M:%S UTC")))
    freshclam.update_defs_from_gcs("gcp-av-definitions")
    freshclam.update_defs_from_freshclam("/tmp/data", "./bin")
    if os.path.exists("/tmp/data/main.cud"):
        os.remove("/tmp/data/main.cud")
        if os.path.exists("/tmp/data/main.cvd"):
            os.remove("/tmp/data/main.cvd")
        freshclam.update_defs_from_freshclam("/tmp/data", "./bin")
    freshclam.upload_defs_to_gcs("gcp-av-definitions", "/tmp/data")
    print("Finished %s\n" % datetime.utcnow().strftime("%Y/%m/%d %H:%M:%S UTC"))
