import os
from datetime import datetime

import clamscan


def scan(data, context):
    """ Handles the scanning of files for viruses when cloud storage triggers the
        finalise event on an object - this happens on create and update
    """
    start_time = datetime.utcnow()
    print("Started at %s\n" % (start_time.strftime("%Y/%m/%d %H:%M:%S UTC")))
    file_path = clamscan.download_object_from_event(data, "/tmp")
    clamscan.update_defs_from_gcs("gcp-av-definitions")
    scan_result = clamscan.scan_file(file_path, "./bin")
    print(
        "Scan of gcs://%s resulted in %s\n"
        % (os.path.join(data["bucket"], data["name"]), scan_result)
    )
    try:
        os.remove(file_path)
    except OSError:
        pass
    if scan_result == "INFECTED":
        clamscan.delete_object_from_event(data)
    print("Finished at %s\n" % datetime.utcnow().strftime("%Y/%m/%d %H:%M:%S UTC"))
