'''
Functions to interface with auth server and ini files.
'''
import configparser
import json
import os
import Common

import requests

CONFIG_RELATIVE_PATH = r"ON Semiconductor\Strata Developer Studio.ini"

USERNAME_SECTION = "Usernames"
USERNAME_OPTION = "usernamestore"
USERNAME_INDEX_OPTION = "usernameindex"

LOGIN_SECTION = "Login"
TOKEN_OPTION = "token"
USER_OPTION = "user"
FIRST_NAME_OPTION = "first_name"
LAST_NAME_OPTION = "last_name"
AUTHENTICATION_SERVER_OPTION = "authentication_server"


def removeLoginInfo(iniPath):
    '''
    Remove login information from ini file.
    NOTE: Call this AFTER you call closeAccount().
    :return:
    '''
    if (os.path.exists(iniPath)):
        config = configparser.ConfigParser()
        config.read(iniPath)
        if USERNAME_SECTION in config:
            config[USERNAME_SECTION][USERNAME_OPTION] = "[]"
            config[USERNAME_SECTION][USERNAME_INDEX_OPTION] = "0"
        else:
            with Common.TestLogger() as logging:
                logging.warning("Could not find config section: " + USERNAME_SECTION)
        if LOGIN_SECTION in config:
            config[LOGIN_SECTION][USER_OPTION] = ""
            config[LOGIN_SECTION][TOKEN_OPTION] = ""
            config[LOGIN_SECTION][FIRST_NAME_OPTION] = ""
            config[LOGIN_SECTION][LAST_NAME_OPTION] = ""
        else:
            with Common.TestLogger() as logging:
                logging.warning("Could not find config section: " + LOGIN_SECTION)

        with open(iniPath, 'w') as configfile:
            config.write(configfile)


def getCloseAccountInfo(iniPath):
    '''
    Get the information needed to close the user's account.
    :return: (token, username, auth server url)
    '''
    if (os.path.exists(iniPath)):
        config = configparser.ConfigParser()
        config.read(iniPath)
        if LOGIN_SECTION in config and TOKEN_OPTION in config[LOGIN_SECTION] and USER_OPTION in config[
            LOGIN_SECTION] and AUTHENTICATION_SERVER_OPTION in config[LOGIN_SECTION]:
            return (config[LOGIN_SECTION][TOKEN_OPTION], config[LOGIN_SECTION][USER_OPTION],
                    config[LOGIN_SECTION][AUTHENTICATION_SERVER_OPTION])
    return ("", "", "")


def closeAccount(iniPath):
    '''
    Close the currently logged in user's account
    :return:
    '''
    with Common.TestLogger() as logging:
        token, username, authUrl = getCloseAccountInfo(iniPath)
        if token != '' and username != '' and authUrl != '':
            result = requests.post(authUrl + "closeAccount", data=json.dumps({"username": username}),
                                   headers={"Content-Type": "application/json", "x-access-token": token})
            if result.status_code == 200:
                logging.info("Closed account for " + username)
            else:
                logging.warning("Could not close account for " + username + " (status code: " + result.status_code + ")")
        else:
            logging.warning("Token, username, or authorization server url is empty")


def deleteLoggedInUser(iniPath):
    '''
    Delete the currently logged in user from auth server and ini file.
    :return:
    '''
    closeAccount(iniPath)
    removeLoginInfo(iniPath)
