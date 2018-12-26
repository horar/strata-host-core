import os
import json
import requests
import hashlib
import time
import datetime

def singup(url, username, password):
    """signup function: Register new user to the cloud services

    Args:
        url: Cloud services url
        username: The username to be registred
        password: The user's password
    Returns:
        return tuple of response status code and response body
    """
    json_body = {
        'firstname': 'firstname',
        'lastname': 'lastname',
        'username': username,
        'password': password,
        'title': 'title',
        'company': 'company',
        'code': 'fGEU'
    }
    response = requests.post(url+'/signup', json_body)
    return response.status_code, response.json()

def login(url, username, password):
    """login function: Authenticate a user from the cloud services

    Args:
        url: Cloud services url
        username: The username
        password: The password
    Returns:
        return tuple of response status code and response body.
        On Successful, response body contains the authentication token.
    """
    json_body = {
        'username': username,
        'password': password,
    }
    response = requests.post(url+'/login', json_body)
    return response.status_code, response.json()

def uploadFile(url, token, file_name, file_path, class_id, file_category):
    """uploadFile function: Upload file to the cloud services

    Args:
        url: Cloud services url
        token: The authentication token
        file_name: The filename
        file_path: The file path on the local hard drive
        class_id: The platform class id to be associate it with on the cloud services
        file_category: The file category. i.e Schematic.
    Returns:
        return tuple of response status code and response body.
    """
    multipart_form_data = {
        'usbpdFile': (file_name, open(file_path, 'rb')),
    }
    json_body = {
        'platform': class_id,
        'version': file_category
    }
    headers = {
        "x-access-token": token
    }
    response = requests.post(url + '/uploadFileUSBPD', data=json_body, files=multipart_form_data, headers=headers)
    return response.status_code, response.text

def timeStamp():
    """uploadFile function: Generates a timestamp of this format Y-m-d H:M:S

    Args:
        Null
    Returns:
        return timestamp in string format
    """
    ts = time.time()
    return datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')

def md5(file_path):
    """md5 function: Generates md5 hash of a given file

    Args:
        file_path: The file path on the local hard drive
    Returns:
        return md5 hash in string format
    """
    hash_md5 = hashlib.md5()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def getFilesMetadata(class_id, path, url, token):
    """getFilesMetadata function: Build list of dictionaries
       [{
           "name":"views1", // from manifest.json file if provided otherwise use directory name
           "file":"schematic.pdf",
           "md5":"9e107d9d372bb6826bd81d3542a419d6",
           "timestamp":"2005-10-30 T 10:45.76"
       }]
    Args:
        class_id: The platform class id to be associate it with on the cloud services
        path: The file path on the local hard drive
        url: Cloud services url
        token: The authentication token
    Returns:
        return list of dictionaries. OR Exception if file upload fails!
    """
    filesMetaData = []
    for dirName, subdirList, fileList in os.walk(path):
        currentDirName = dirName.split(os.path.sep)[-1]
        for fname in fileList:
            fileInfo = dict()
            fileInfo["name"] = currentDirName
            fileInfo["file"] = fname
            filePath = dirName + "/" + fname
            fileInfo["md5"] = md5(filePath)
            fileInfo["timestamp"] = timeStamp()
            filesMetaData.append(fileInfo)
            result = uploadFile(url, token, fname, filePath, class_id, currentDirName)
            if result[0] == 200:
                print "File {} uploaded successfully".format(fname)
            else:
                error_message = "Could not upload file located in:{} for class Id:{}. Error message:{}".format(filePath,class_id, result[1])
                raise ValueError(error_message)

    return filesMetaData

def pushGateway(url, document_name, payload):
    """pushGateway function: Pushes json document to the couchbase sync-gateway

    Args:
        url: The couchbase sync-gateway url
        document_name: The document key
        payload: The JSON format to be pushed to the couchbase sync-gateway
    Returns:
        return True on successful, False otherwise
    """
    print "\n\n\nPUSH TO Sync Gateway : " + document_name
    REV_KEY_GET = '_rev'
    REV_KEY_PUT = 'rev'
    # ----------------- Deploy to Gateway Sync --------------
    # Get the latest rev; We need this to PUT a modified document
    rev = 0
    doc_found = False

    unique_document_name = document_name
    url_request = "{}/{}".format(url, unique_document_name)
    print "request: " + url_request
    response = requests.get(url_request)

    # See if document exists
    print "Searching Gateway for {} document".format(unique_document_name)
    if response.status_code == 404:
        print "Document not found. Creating first rev document."
        doc_found = False
    elif response.status_code == 200:
        print "Document Found!"
        doc_found = True
        json_document_set = response.json()
        if REV_KEY_GET not in json_document_set:
            print "No revision exists!. Make the document before starting."
            return False
        else:
            rev = json_document_set[REV_KEY_GET]
            print "Revision is " + rev
    else:
        print "result to request is {} {}".format(response.status_code, response.reason)
        doc_found = False

    # Build PUT request
    if doc_found:
        put_cmd = "{}?new_edits=true&rev={}".format(url_request, rev)
    else:
        put_cmd = "{}?new_edits=true".format(url_request)

    print "COMMAND: " + put_cmd
    response = requests.put(put_cmd, data=json.dumps(payload))
    if response.status_code != 201:
        print "PUT request failed: {} {}".format(response.status_code, response.reason)
        return False
    else:
        print "PUT request successful {} {}".format(response.status_code, response.reason)

    json_document_set = response.json()
    if REV_KEY_PUT not in json_document_set:
        print "No revision exists!"
        return False
    else:
        rev = json_document_set[REV_KEY_PUT]
        print "Revision is now " + rev

    return True
