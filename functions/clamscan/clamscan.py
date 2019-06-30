import base64
import binascii
import errno
import hashlib
import os
from subprocess import PIPE, STDOUT, Popen

import requests
from google.api_core.exceptions import NotFound
from google.auth.exceptions import DefaultCredentialsError
from google.cloud import storage

DEF_FILES = ["main.cvd", "daily.cvd", "bytecode.cvd"]


def get_client():
    """ Return an instance for working with gcs
    """
    return storage.Client()


def create_dir(directory):
    """ Create a directory if it doesn't already exist
    """
    if not os.path.exists(directory):
        try:
            print("Attempting to create directory %s.\n" % directory)
            os.makedirs(directory)
        except OSError as exc:
            if exc.errno != errno.EEXIST:
                raise


def download_object_from_event(event, path):
    """ Extracts gcs object from event data and downloads it from gcs
    """
    local_path = os.path.join(path, event["bucket"], event["name"])
    create_dir(os.path.join(path, event["bucket"]))
    client = get_client()
    bucket = client.get_bucket(event["bucket"])
    blob = bucket.blob(event["name"])
    blob.download_to_filename(local_path)
    return local_path


def delete_object_from_event(event):
    """ Extracts gcs object from event data and removes it from gcs
    """
    client = get_client()
    bucket = client.get_bucket(event["bucket"])
    blob = bucket.blob(event["name"])
    blob.delete()


def md5_from_file(filename):
    """ Generates an md5 hash from a file
    """
    hash_md5 = hashlib.md5()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


def md5_from_gcs_object(bucket, key):
    """ Generates md5 hash from cloud storage object. Note that we also have to do a
        little hacking at the data to make it a true md5 as google base64 encodes their
        mds hashes.
    """
    try:
        client = get_client()
        bucket = client.get_bucket(bucket)
        blob = bucket.get_blob(key)
        if blob:
            return binascii.hexlify(base64.urlsafe_b64decode(blob.md5_hash)).decode(
                "utf-8"
            )
    except DefaultCredentialsError:
        print("Unable to authenticate with Google Cloud Storage")
    except NotFound:
        print("Bucket does not exist!")
    except Exception as e:
        print("An unexpected exceptions was raised from Google. {}".format(e))
    return None


def update_defs_from_gcs(bucket_name):
    """ Pulls down definitions from cloud storage bucket if we don't already have
        the latest version.
    """
    create_dir("/tmp/data")
    client = get_client()
    bucket = client.get_bucket(bucket_name)
    for filename in DEF_FILES:
        local_path = os.path.join("/tmp/data", filename)
        gcs_md5 = md5_from_gcs_object(bucket_name, filename)
        if os.path.exists(local_path) and md5_from_file(local_path) == gcs_md5:
            print("Not downloading %s because local md5 matches gcs." % filename)
            continue
        if gcs_md5:
            print("Download definition file %s from gcs://%s" % (filename, bucket_name))
            blob = bucket.blob(filename)
            blob.download_to_filename(local_path)


def slack_notification(message, color):
    """ Sends a notification message to slack channel.
    """
    if os.environ.get("SLACK_WEBHOOK_URL"):
        print("Sending slack notifications...")
        payload = {"color": color, "text": message}
        url = "{}".format(os.environ["SLACK_WEBHOOK_URL"])
        requests.post(url, json=payload)
        return payload
    return None


def scan_file(filepath, clamscan_path):
    """ Scans the file at the passed filepath for viruses and returns the result.
    """
    print("Starting clamscan of {}".format(filepath))
    av_env = os.environ.copy()
    av_env["LD_LIBRARY_PATH"] = clamscan_path
    av_proc = Popen(
        ["./bin/clamscan", "-v", "-a", "--stdout", "-d", "/tmp/data", filepath],
        stderr=STDOUT,
        stdout=PIPE,
        env=av_env,
    )
    output = av_proc.communicate()[0]
    print("clamscan output:\n%s" % output)
    if av_proc.returncode == 0:
        msg = "Detected upload of CLEAN file `{}` in GCS. :white_check_mark:".format(
            filepath
        )
        slack_notification(msg, "good")
        return "CLEAN"
    elif av_proc.returncode == 1:
        msg = (
            "Detected upload of INFECTED file `{}` in GCS. File has been removed! "
            ":heavy_exclamation_mark:"
        ).format(filepath)
        slack_notification(msg, "danger")
        return "INFECTED"
    msg = "Unexpected exit code from ClamAV when scanning: %s.\n" % av_proc.returncode
    slack_notification(msg, "warning")
    print(msg)
    raise Exception(msg)
