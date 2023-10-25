#!/usr/bin/env python

import re
import urllib.parse
import time
import sys
import csv
import argparse
from seleniumbase import SB#, Driver, page_actions
from seleniumbase import BaseCase as SBBaseCase
from selenium.common.exceptions import NoSuchElementException, NoSuchWindowException

#SBBaseCase.main(__name__, __file__)

workspace_re = re.compile(r'https?:\/\/(?:\w+\.?)terra.bio\/\\?#workspaces\/(?P<billing_account>[\w\-_]+)\/(?P<workspace_id>[^\/]+)\/?.*')
user_from_email_re = re.compile(r'(?P<user>[^@]+)@.*')

workspace_url_prefix="https://app.terra.bio/#workspaces"

parser = argparse.ArgumentParser(
            description="""This signs in to a fresh Google account, and changes the user's password."""
            )

parser.add_argument('credentials_tsv', type=argparse.FileType('r'), help='User credentials, one user per row. Columns: google_account_email,google_account_password,google_account_password_old')
parser.add_argument('--change_password', 
                        dest='change_password',
                        action='store_true',  
                        help="""If specified, a password change will be performed""")
parser.add_argument('--clone_workspace', 
                        dest='clone_workspace',
                        type=str,
                        default=None,
                        nargs='+',  
                        help="""If specified, workspaces specified will be cloned by the authenticated user. Workspaces must be entered as full Terra URIs""")

parser.add_argument('--delete_workspace', 
                        dest='delete_workspace',
                        type=str,
                        default=None,
                        nargs='+',  
                        help="""If specified, workspaces specified will be deleted by the authenticated user. Workspaces must be entered as full Terra URIs. If workspaces are specified for cloning and deletion, the deletion will occur first""")

class TrainingUser(object):

    def __init__(self, username, password, *args, **kwargs):
        #super().setUp()
        #super().__init__(*args, **kwargs)

        def noop_tearDown():
            print("bypassing seleniumbase SB() teardown...")

        # use undetectable mode
        ctx=SB(uc=True) #, demo=True
        # seleniumbase has a great contextmanager that initializes many things sensibly
        # but does not offer a similarly good non-generator persistent class
        # so let's use the context manager as if it were such a class
        self.sb=ctx.__enter__()
        # one (understandable) downside to the context manager is that it does not have an
        # equivalent parameter to the seleniumbase "--reuse-session" flag, meaning
        # browser windows will be blown away between (Python) function calls using the browser driver
        # However, an ugly workaround is to:
        # override the default seleniumbase tearDown() function
        # so the session (with authentication cookies, etc.) persists across operations
        # and also store the original tearDown() function for eventual cleanup 
        self.sb.sbTearDown = self.sb.tearDown
        self.sb.tearDown = noop_tearDown

        self.username=None

        self.logged_in_to_google=False
        if self.logged_in_to_google == False:
            self.login_to_account(username,password)


    def hide_annoyances(self):
        """
            hide cookie banners, feedback modals, and the like
        """
        # hide cookie bannder
        #cookie_banner_selector='aside[aria-label="Cookie consent banner"] > div > div:contains("Agree")'
        #cookie_banner_selector='div:contains("Agree")'
        cookie_banner_selector='aside[aria-label="Cookie consent banner"] div:nth-of-type(2) div'
        #cookie_banner_selector='aside[aria-label="Cookie consent banner"] div:contains("Agree")'
        #self.sb.click('div:contains("Agree")')
        #self.sb.click('//div[contains(.,"Agree") and @role="button"]')
        if self.sb.is_element_present(cookie_banner_selector, by="css selector"):
            self.sb.click(cookie_banner_selector)
            self.sb.sleep(1)

        # hide feedback request modal
        if self.sb.is_element_present('.ask-me-later', by="css selector"):
            self.sb.click('.ask-me-later')
            self.sb.sleep(1)

        # hide warning on non-Chrome browsers
        if self.sb.is_element_present('a#buttonCloseUpdateBrowser', by="css selector"):
            self.sb.click('a#buttonCloseUpdateBrowser')
            self.sb.sleep(1)


    def login_to_account(self, username, password):
        print(f"Logging in to user: {username}")

        self.username=username

        self.sb.open("https://www.google.com/gmail/about/")
        self.sb.click('a[data-action="sign in"]')
        self.sb.type('input[type="email"]', f"{username}")
        self.sb.click('button:contains("Next")')
        self.sb.sleep(5)
        self.sb.type('input[type="password"]', password)
        self.sb.click('button:contains("Next")')
        self.sb.sleep(2)

        # ToS agreement selector
        tos_agree_button_selector='input[value="I understand"]'
        if self.sb.is_element_present(tos_agree_button_selector, by="css selector"):
            self.sb.click(tos_agree_button_selector)

        #self.sb.click('button:contains("I understand")') #<input type="submit" class="MK9CEd MVpUfe" jsname="M2UYVd" jscontroller="rrJN5c" jsaction="aJAbCd:zbvklb" name="confirm" value="I understand" id="confirm">

        self.sb.sleep(2)

        self.logged_in_to_google=True

    def change_password(self, password_new, initial_password_change=False):
        if initial_password_change:
            print("passwd path 1")
            
            # initial prompt for password change
            if self.sb.is_element_present('input[name="Password"]', by="css selector"):
                self.sb.type('input[name="Password"]', f"{password_new}")
                self.sb.type('input[name="ConfirmPassword"]', f"{password_new}")

            # future prompts for password change
            if self.sb.is_element_present('input[name="Passwd"]', by="css selector"):
                self.sb.type('input[name="Passwd"]', f"{password_new}")
                self.sb.type('input[name="ConfirmPasswd"]', f"{password_new}")

            self.sb.sleep(1)
            #self.sb.click('a[data-action="Change password"]')
            #self.sb.click('button:contains("Change password")')
        else:
            print("passwd path 2")
            self.sb.open("https://myaccount.google.com/signinoptions/password")
            self.sb.type('input[name="password"]', f"{password_new}")
            self.sb.type('input[name="confirmation_password"]', f"{password_new}")
            #self.sb.click('button:contains("Change password")')

        for change_passwd_button_selector in ['button:contains("Change password")','button:contains("Next")','input[value="Change password"]','input[value="Next"]']:
            if self.sb.is_element_present(change_passwd_button_selector, by="css selector"):
                self.sb.click(change_passwd_button_selector)
                break
        self.sb.sleep(3)

    def check_gmail_inbox(self):
        pass

    
    def terra_oauth_flow(self):
        assert self.logged_in_to_google==True, "Terra login can only be performed following google authentication"

        # attempt to open page listing workspaces
        self.sb.open("https://app.terra.bio/#workspaces")
        self.sb.sleep(5)
        self.hide_annoyances()

        # initial user setup on Terra (enter first+last names)

        # store the current window handle to restore later
        main_window = self.sb.driver.current_window_handle

        # click the sign-in button, which opens the OAuth popup
        self.sb.click("div#signInButton")
        # wait for OAuth popup to appear
        self.sb.sleep(5)

        # under the assumption that there are only two window handles,
        # switch to the one that isn't the known-main window (i.e. the popup)
        for handle in self.sb.driver.window_handles: 
            if handle != main_window: 
                popup = handle
                self.sb.switch_to_window(popup)
                # give the system a moment to switch to the popup
                self.sb.sleep(1)
                
                # selct SSO via Google OAuth
                self.sb.click('button:contains("Sign in with Google")')
                self.sb.sleep(3)

                try:
                    # Google sometimes but not always asks the user to pick an account to use
                    # even in an otherwise sandboxed session. Repeat OAuth logins often omit this step
                    # but not always.
                    # If presented with the user's account, click it.
                    if self.sb.is_element_present(f'div[data-identifier="{self.username}"]', by="css selector"):
                        self.sb.click(f'div[data-identifier="{self.username}"]')
                        self.sb.sleep(7)
                    #break
                # selenium will throw an error checking for the username because the window will close
                # in the no-account-selection case before selenium can inspect it
                # so just catch and continue gracefully
                except (NoSuchWindowException, NoSuchElementException):
                    pass

        # switch back to the main window just in case it did not occur automatically 
        # when the OAuth pop-up closed
        self.sb.switch_to_window(main_window)
        
        self.sb.sleep(5)
        self.hide_annoyances()

    def complete_terra_registration(self):
        # the user's first and last names are saved if the registration has been partially completed
        # so only complete the form if they're visible

        if self.sb.is_element_visible("//input[@id=//label[contains(.,'First Name')]/@for]", by="css selector"):
            # enter first and last "names" for user, 
            # selecting the relevant inputs based on what their labels say
            # (since the Terra element ID values change load-to-load and cannot be relied upon as selectors)
            self.sb.type("//input[@id=//label[contains(.,'First Name')]/@for]", self.username)
            self.sb.type("//input[@id=//label[contains(.,'Last Name')]/@for]", self.username)
            self.sb.sleep(1)
            # Register the Terra account
            self.sb.click('//div[contains(.,"Register") and @role="button"]')
            #self.sb.click('div:contains("Register")')
            self.sb.sleep(2)
            # agree to the silly GDPR cookie banner
            #self.sb.click('div:contains("Agree")')
            self.sb.wait_for_element_not_visible('div:contains("Register")', by="css selector", timeout=60)


        self.hide_annoyances()
        #self.sb.sleep(5)

        # accept the Terra ToS
        #self.sb.click('div:contains("Accept")')
        if self.sb.is_element_visible('div:contains("Accept")', by="css selector"):
            print('[Accept] IS visible')
            self.sb.scroll_into_view('div:contains("Accept")', by="css selector", timeout=None)
            #self.sb.click('//div[contains(.,"Accept") and @role="button"]')
            self.sb.hover_and_click('//div[contains(.,"Accept") and @role="button"]',
                                    '//div[contains(.,"Accept") and @role="button"]',
                                    hover_by="css selector",
                                    click_by="css selector",
                                    timeout=None)
            self.sb.wait_for_element_not_visible('div:contains("Accept")', by="css selector", timeout=60)
        else:
            print('[Accept] IS NOT visible')

    def login_to_terra(self):

        self.terra_oauth_flow()

        # open the workspace view if not already open
        self.sb.open_if_not_url("https://app.terra.bio/#workspaces")
        self.sb.sleep(2)
        self.hide_annoyances()

        if self.sb.is_element_present('span:contains("MY WORKSPACES")', by="css selector"):
            print("user has completed initial Terra registration")
        else:
            print("user has NOT completed initial Terra registration")
            self.complete_terra_registration()

    def delete_workspace(self, billing_project, workspace_id):

        # open the workspace to delete
        built_workspace_url = f"{workspace_url_prefix}/{billing_project}/{workspace_id}"
        print(f"built_workspace_url: {built_workspace_url}")
        self.sb.open(built_workspace_url)
        self.sb.sleep(5)

        # # clone the workspace
        workspace_action_menu_selector='div[aria-label="Workspace Action Menu"] svg'
        if self.sb.is_element_present(workspace_action_menu_selector, by="css selector"):
            self.sb.click(workspace_action_menu_selector)
            self.sb.sleep(4)

            # workaround for the element seemingly having 0 size (due to Chrome bug?)
            #self.sb.scroll_into_view('div:contains("Clone")', by="css selector", timeout=None)
            #self.sb.js_click('div:contains("Clone")', by="css selector", all_matches=False, timeout=None, scroll=True)
            #self.sb.click('div:contains("Clone")')
            self.sb.click('div[role="menuitem"] > div:contains("Delete")')
            #self.sb.click_visible_elements('div:contains("Clone")', by="css selector", limit=0, timeout=None)
            self.sb.sleep(4)

            self.sb.type('input#delete-workspace-confirmation', "Delete Workspace")
            self.sb.click('//div[contains(.,"Delete workspace") and @role="button"]')
            self.sb.sleep(20)
            self.sb.open_if_not_url("https://app.terra.bio/#workspaces")


    def clone_workspace(self, billing_project, workspace_id):
        #self.sb.type(self.sb.convert_xpath_to_css(xpath), self.username)
        # xpath selector for first name field:
        # $x("//label[contains(.,'First Name')]/@for")[0].value

        # working xpath to get input corresponding to label containing text "First Name":
        # "//input[@id=//label[contains(.,'First Name')]/@for]"

        # open the workspace to copy
        built_workspace_url = f"{workspace_url_prefix}/{billing_project}/{workspace_id}"
        print(f"built_workspace_url: {built_workspace_url}")
        self.sb.open(built_workspace_url)
        self.sb.sleep(5)

        # # clone the workspace
        workspace_action_menu_selector='div[aria-label="Workspace Action Menu"] svg'
        if self.sb.is_element_present(workspace_action_menu_selector, by="css selector"):
            self.sb.click(workspace_action_menu_selector)
            self.sb.sleep(4)

            # workaround for the element seemingly having 0 size (due to Chrome bug?)
            #self.sb.scroll_into_view('div:contains("Clone")', by="css selector", timeout=None)
            #self.sb.js_click('div:contains("Clone")', by="css selector", all_matches=False, timeout=None, scroll=True)
            #self.sb.click('div:contains("Clone")')
            self.sb.click('div[role="menuitem"] > div:contains("Clone")')
            #self.sb.click_visible_elements('div:contains("Clone")', by="css selector", limit=0, timeout=None)
            self.sb.sleep(4)

            # "                            //input[@id=//label[contains(.,'Last Name')]/@for]
            #workspace_name_input_selector="//input[@id=//label[contains(.,'Workspace name')]/@for]"
            workspace_name_input_selector="//input[@id=//label[contains(.,'Workspace name')]/@for]"
            #workspace_name_input_selector="//input[@id=//label[contains(.,'Workspace name')]/@for]/@value"
            #workspace_name_input_css_selector = self.sb.convert_xpath_to_css(workspace_name_input_selector)
            terra_suggested_clone_name=self.sb.get_text(workspace_name_input_selector, by="css selector", timeout=None)
            print(f"terra_suggested_clone_name: {terra_suggested_clone_name}")

            user_from_email = user_from_email_re.search(self.username)
            print(f"user_from_email: {user_from_email}")

            # workspace names must be (globally?) unique, so append the user's name to the workspace title
            cloned_workspace_name=f"{terra_suggested_clone_name}_{user_from_email['user']}"
            self.sb.type(f"{workspace_name_input_selector}", cloned_workspace_name)
            self.sb.sleep(2)
            #self.sb.click('div:contains("Clone Workspace")')
            self.sb.click('//div[contains(.,"Clone Workspace") and @role="button"]')
            
            self.sb.sleep(15)
            self.sb.wait_for_element_not_visible(workspace_name_input_selector, by="css selector", timeout=70)
            

            self.hide_annoyances()

            # navigate to the copied workspace
            built_workspace_url = f"{workspace_url_prefix}/{billing_project}/{urllib.parse.quote(cloned_workspace_name)}"
            print(f"built_workspace_url (clone): {built_workspace_url}")
            self.sb.open(built_workspace_url)
            self.sb.sleep(5)

        # self.sb.click("div#unique-id-5 svg")
        # self.sb.click("div#unique-id-6 > div:nth-of-type(2) > div > div > div")
        # self.sb.click("div#modal-root div div:nth-of-type(7) div:nth-of-type(2)")
        # self.sb.double_click("input.focus-style")
        # self.sb.type("input.focus-style", "VEME NGS 2023 clone")
        # self.sb.click("div#modal-root div div:nth-of-type(3) div:nth-of-type(2) svg")
        # self.sb.click("div#modal-root div div:nth-of-type(8) div:nth-of-type(2)")


def read_credentials(credentials_tsv):
    """
        credentials_tsv should have the following columns (somewhere):
        google_account_email,google_account_password_new,google_account_password_old
    """
    reader = csv.DictReader(credentials_tsv, dialect='excel-tab')
    for row in reader:
        yield (row["google_account_email"],row["google_account_password_old"],row["google_account_password"])

def parse_workspace_url(workspace_url):
    workspace_parsed_info = workspace_re.search(workspace_url)
    if workspace_parsed_info is not None:
        billing_project = workspace_parsed_info["billing_account"]
        workspace_id = workspace_parsed_info["workspace_id"]

        workspace_id_url_decoded = urllib.parse.unquote(workspace_id)

        print(f"workspace_id: {workspace_id}")
        print(f"workspace_id_url_decoded: {workspace_id_url_decoded}")

        return (billing_project,workspace_id)

if __name__ == "__main__":
    if len(sys.argv)==1:
        parser.print_help()
        sys.exit(0)

    args = parser.parse_args()

    # initial login to account to agree to ToS and change password
    for idx,(user_email,pw_old,pw_new) in enumerate(read_credentials(args.credentials_tsv)):
        print(f"{idx}\t{user_email}\t{pw_old}\t{pw_new}")
        
        authed_user = TrainingUser(user_email, pw_old if args.change_password else pw_new)

        if args.change_password:
            authed_user.change_password(pw_new, initial_password_change=True)

        authed_user.login_to_terra()

        if args.delete_workspace!=None and len(args.delete_workspace)>0:
            for workspace_url in args.delete_workspace:
                print(f"DELETING workspace_url: {workspace_url}")

                billing_project,workspace_id = parse_workspace_url(workspace_url)
                authed_user.delete_workspace(billing_project, workspace_id)

        if args.clone_workspace!=None and len(args.clone_workspace)>0:                
            for workspace_url in args.clone_workspace:
                print(f"CLONING workspace_url: {workspace_url}")

                billing_project,workspace_id = parse_workspace_url(workspace_url)
                authed_user.clone_workspace(billing_project, workspace_id)
            
            
            authed_user.sb.sbTearDown()

            if args.change_password:
                time.sleep(95)
            else:
                time.sleep(3)
