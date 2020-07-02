import os
import configparser
import json
import requests

CONFIG_RELATIVE_PATH = r"ON Semiconductor\Strata Developer Studio.ini"

USERNAME_SECTION = "Usernames"
USERNAME_OPTION = "userNameStore"

LOGIN_SECTION = "Login"
TOKEN_OPTION = "token"
USER_OPTION = "user"
FIRST_NAME_OPTION = "first_name"
LAST_NAME_OPTION = "last_name"
AUTHENTICATION_SERVER_OPTION = "authentication_server"

def removeLoginInfo():
    '''
    Remove login information from ini file.
    NOTE: Call this AFTER you call closeAccount().
    :return:
    '''
    appdataPath = os.getenv('APPDATA')
    if(appdataPath):
        configPath = os.path.join(appdataPath, CONFIG_RELATIVE_PATH)
        if(os.path.exists(configPath)):
            config = configparser.ConfigParser()
            config.read(configPath)

            config[USERNAME_SECTION][USERNAME_OPTION] = "[]"

            config[LOGIN_SECTION][USER_OPTION] = ""
            config[LOGIN_SECTION][TOKEN_OPTION] = ""
            config[LOGIN_SECTION][FIRST_NAME_OPTION] = ""
            config[LOGIN_SECTION][LAST_NAME_OPTION] = ""

            with open(configPath, 'w') as configfile:
                config.write(configfile)


def getCloseAccountInfo():
    '''

    :return: (token, username, auth server url)
    '''
    appdataPath = os.getenv('APPDATA')
    if(appdataPath):
        configPath = os.path.join(appdataPath, CONFIG_RELATIVE_PATH)
        if(os.path.exists(configPath)):
            config = configparser.ConfigParser()
            config.read(configPath)
            return (config[LOGIN_SECTION][TOKEN_OPTION], config[LOGIN_SECTION][USER_OPTION], config[LOGIN_SECTION][AUTHENTICATION_SERVER_OPTION])


def closeAccount():
    '''
    Close the currently logged in user's account
    :return:
    '''
    token, username, authUrl = getCloseAccountInfo()
    if token != '' and username != '' and authUrl != '':
        result = requests.post(authUrl + "closeAccount", data = json.dumps({"username": username}), headers = {"Content-Type":"application/json","x-access-token" :token})
        if result.status_code == 200:
            print("Closed account for " + username)
        else:
            print("Could not close account for " + username + " (status code: " + result.status_code + ")")
    else:
        print("Token, username, or authorization server url is empty")
def deleteLoggedInUser():
    '''
    Delete the currently logged in user from auth server and ini file.
    :return:
    '''
    closeAccount()
    removeLoginInfo()

if __name__ == "__main__":
    deleteLoggedInUser()
