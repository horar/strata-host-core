import os
import argparse
import json
from api import login, singup, getFilesMetadata, pushGateway


parser = argparse.ArgumentParser(description='Build/Push Couchbase document and upload files to cloud services')
parser.add_argument('--config', type=str, default="./config.json", help='configuration file for sync_gateway and cloud services url')
parser.add_argument('directory', type=str, help='The path of the content')
parser.add_argument('classId', type=str, help='Platform class ID')
parser.add_argument('verboseName', type=str, help='Platform verbose name')


args = parser.parse_args()

configuration_data = {}
# Load configuration file

with open(args.config) as f:
    configuration_data = json.load(f)

#Global
SYNC_GATEWAY_URL = ''
CLOUD_SERVICE_USERNAME = 'deplyment_script_username'
CLOUD_SERVICE_PASSWORD = 'password!@#'
CLOUD_SERVICE_URL = ''
CLOUD_SERVICE_ACCESS_TOKEN = ''


# Index of the directory to upload its contents.
# ['dirA', 'dirB', 'dirC'] where the path looks like this. /dirA/dirB/dirC
# This will be dirC
UPLOAD_DIRECTORY_INDEX = 2

# Used for program exist status
Successful = 0
Error = 1

def main():
    SYNC_GATEWAY_URL = "{}/{}".format(configuration_data["sync_gateway_url"], configuration_data["sync_gateway_db"])
    CLOUD_SERVICE_URL = configuration_data["cloud_services_url"]

    signup_result = singup(CLOUD_SERVICE_URL, CLOUD_SERVICE_USERNAME, CLOUD_SERVICE_PASSWORD)
    print  signup_result[1]
    if signup_result[0] == 200:
        CLOUD_SERVICE_ACCESS_TOKEN = signup_result[1]["token"]
    else:
        CLOUD_SERVICE_ACCESS_TOKEN = login(CLOUD_SERVICE_URL, CLOUD_SERVICE_USERNAME, CLOUD_SERVICE_PASSWORD)[1]["token"]

    # Set the directory you want to start from
    rootDir = args.directory

    depth = len(rootDir.split(os.path.sep))

    classId = args.classId
    verboseName = args.verboseName

    json_document = dict()

    json_document["channels"] = classId
    json_document["name"] = verboseName
    json_document["documents"] = dict()

    for dirName, subdirList, fileList in os.walk(rootDir):
        currentDirName = dirName.split(os.path.sep)[-1]
        currentDepth = len(dirName.split(os.path.sep)) - depth
        if (currentDepth == UPLOAD_DIRECTORY_INDEX):
            try:
                json_document["documents"][currentDirName] = getFilesMetadata(classId, dirName, CLOUD_SERVICE_URL,
                                                                      CLOUD_SERVICE_ACCESS_TOKEN)
            except ValueError as err:
                print err.message
                exit(Error)

    if pushGateway(SYNC_GATEWAY_URL, classId, json_document):
        print "Document has been pushed successfully to the sync-gateway!"
        exit(Successful)

    print "Could not push to the sync-gateway"
    exit(Error)


if __name__ == '__main__':
    main()