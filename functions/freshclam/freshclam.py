import base64
import binascii
import errno
import hashlib
import os

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


def md5_from_file(filename):
    """ Generates an md5 hash from a file
    """
    hash_md5 = hashlib.md5()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


def md5_from_gcs_object(bucket, key):
    """ Generates md5 hash from cloud storage object
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


def upload_defs_to_gcs(bucket_name, local_path):
    """ Upload clam av virus definition files to google cloud storage bucket.
        Only uploads files if they are different to what's already present in gcs.
    """
    client = get_client()
    bucket = client.get_bucket(bucket_name)
    for filename in DEF_FILES:
        local_file_path = os.path.join(local_path, filename)
        if os.path.exists(local_file_path):
            local_file_md5 = md5_from_file(local_file_path)
            if local_file_md5 != md5_from_gcs_object(bucket_name, filename):
                print(
                    "Uploading %s to gcs://%s"
                    % (local_file_path, os.path.join(bucket_name, filename))
                )
                blob = bucket.blob(filename)
                blob.upload_from_filename(local_file_path)
            else:
                print("Not uploading %s because md5s match." % filename)
    msg = "ClamAV Virus definitions have been updated! :white_check_mark:"
    slack_notification(msg, "good")


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


def update_defs_from_freshclam(path, freshclam_path=""):
    """ Updates virus definitions from clamav and stores them to a local path.
    """
    for cvd in DEF_FILES:
        url = "https://database.clamav.net/{}".format(cvd)
        r = requests.get(url, allow_redirects=True)
        open(os.path.join(path, cvd), "wb").write(r.content)
