import Common

def Logout(ui):
    ui.PressButton(Common.USER_ICON_BUTTON)
    ui.PressButton(Common.LOGOUT_BUTTON)

def Login(ui, username, password):
    ui.SetEditText(Common.USERNAME_EDIT, username)
    ui.SetEditText(Common.PASSWORD_EDIT, password)
    ui.PressLoginButton()

def Register(ui, username, password, firstName, lastName, title, company):
    ui.SetEditText(Common.EMAIL_EDIT, username)
    ui.SetEditText(Common.REGISTER_PASSWORD_EDIT, password)
    ui.SetEditText(Common.FIRST_NAME_EDIT, firstName)
    ui.SetEditText(Common.LAST_NAME_EDIT, lastName)
    ui.SetEditText(Common.TITLE_EDIT, title)
    ui.SetEditText(Common.COMPANY_EDIT, company)
    ui.PressConfirmCheckbox()

    ui.PressRegisterButton()